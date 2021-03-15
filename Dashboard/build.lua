--[[

This Lua script recursively iterates and finds all html files in the
AdminLTE directory. All HTML files that include the following start
and end comments have the "page content" extracted and copied to the
same directory in AdminLTE.new

<!-- Main content -->
page content
<!-- /.content -->

See Figure 2 in the tutorial for additional details:
https://makoserver.net/articles/How-to-Build-an-Interactive-Dashboard-App

In addition, the script also extracts the left side HTML menu. (See
"content framed in green" in Figure 1 in the tutorial).

The complete HTML code for the menu is XML compliant and we can use an
XML parser to parse the HTML and create an XML tree out of it. We use
this tree to create a Lua table that represents the content put into
menu.json. The Lua table is converted to JSON and saved as
AdminLTE.new/.lua/menu.json

Note: this script uses extended features not found in stock Lua and
requires the eXtended xlua: https://makoserver.net/download/overview/

--]]


local dirname=arg and arg[1] or "AdminLTE"
local newdir=dirname..".new"
local io=ba.openio"home"
if not io:stat(dirname) then print("Not found:",dirname) return end
local fmt=string.format

assert(
       (io:stat(newdir) or io:mkdir(newdir)) and
       (io:stat(newdir.."/.lua") or io:mkdir(newdir.."/.lua")) and
       (io:stat(newdir.."/.lua/www") or io:mkdir(newdir.."/.lua/www"))
    )

local wwwIo=ba.mkio(io,newdir.."/.lua/www")
assert(wwwIo)

-- Returns a recursive iterator that iterates all files.
function recDirIter(dirname)
   local retVal=nil
   -- Recursive directory iterator
   local function doDir(dirname)
      for file,isdir in io:files(dirname, true) do
         if file ~= "." and file ~= ".." then
            if isdir then
               -- Recurse into directory
               if not file:find"docs$" then
                  doDir(fmt("%s/%s",dirname,file))
               end
            else
               retVal=fmt("%s/%s",dirname,file)
               coroutine.yield() -- Yield to (A) 
            end
         end
      end
      retVal=nil
   end
   local co = coroutine.create(function() doDir(dirname) end)
   return function() -- Return iterator
      coroutine.resume(co)
      return retVal
   end
end


-- Read or write file. Write if 'data'
local function file(io,name,data)
   local fp,ret,err
   if data then
      fp,err=io:open(name,"w")
      if fp then ret,err = fp:write(data) end
   else
      fp,err=io:open(name)
      if fp then ret=fp:read"*a" end
   end
   if fp then fp:close() end
   if not ret then
      return nil,fmt("%s: %s",name,err)
   end
   return ret
end


-- Trim string at both ends
local function trim(txt)
   return txt:gsub("^%s*(.-)%s*$", "%1")
end

local function findFile(href)
   return wwwIo:stat(href) or href:find"^http?s://"
end

-- Designed exclusively for extracting menu elements from AdminLTE
local function buildMenu(ul)
   local ix=1
   local menuL={} -- menu list
   for k,v in ipairs(ul) do
      if v.type=="element" then
         local menu
         if v.elements then
            local href=v.elements.a.attributes.href
            local p=v.elements.a.elements.p
            local i=v.elements.a.elements.i
            if findFile(href) or v.elements.ul then
               menu={
                  name=trim(p.text),
                  href=href:match"^./(.+)" or href,
                  class=i.attributes.class
               }
               if(v.elements.ul) then -- sub menu
                  menu.sub=buildMenu(v.elements.ul)
               end
            else
               print(fmt("Skipping menu item: %s (%s)",href,trim(p.text)))
            end
         else
            menu={name=trim(v.text)}
         end
         table.insert(menuL,menu)
      end
      ix=ix+1
   end
   return menuL
end

-- Parse the HTML (data): <nav class="mt-2"> data </nav>
local function buildNav(data)
   data=data:gsub("&","&amp;") -- Convert to valid XML.
   local parser=xparser.create((require("xml2table")))
   local st,doc,error = parser:parse(data) -- Parse HTML using XML parser.
   assert(st == 'DONE')
   -- Iterate parsed XML elements and build menu
   local menuL=buildMenu(doc.elements.ul,"")
   assert(#menuL > 0)
   -- Save as menu.json
   local json = "//Pretty format this file by using: https://jsonformatter.org/\n\n"
   assert(file(io,newdir.."/.lua/menu.json",json..ba.json.encode(menuL)))
end

local function buildPage(fn,data)
   fn=fn:match".-/(.+)"
   print("Building",fn)
   local path = fn:match"(.-/)[^/]+$"
   if path then
      local dir=""
      for n in path:gmatch"(.-)/" do
         dir=dir.."/"..n
         assert(wwwIo:stat(dir) or wwwIo:mkdir(dir), fmt("Cannot create %s",wwwIo:realpath(dir)))
      end
   end
   assert(file(wwwIo,fn,data))
   return fn
end

local navData
for name in recDirIter(dirname) do
   if name:find"%.html$" then
      local data = file(io,name)
      local page=data:match"<!%-%- Main content %-%->(.-)<!%-%- /.content %-%->"
      if page then
         if not navData then
            navData=data:match'<nav class="mt%-2">(.-)</nav>'
            assert(navData, "Cannot extract left navigation menu data")
         end
         name=buildPage(name,page)
         local js = data:match"<!%-%-%s+Page%s+specific%s+script%s+%-%->%s*<script>(.-)</script>"
         if js then -- page specific JS code
            local jsname=fmt("%s.js",name:match"(.-)%.[^%.]+$")
            print("Creating",jsname)
            file(wwwIo,jsname, js) 
         end
      else
         print("Skipping",name)
      end
   end
end

print("\nBuilding", "menu.json")
buildNav(navData)
