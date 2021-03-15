
-- Mini Content Management System (CMS) designed for the AdminLTE dashboard.

local fmt=string.format

-- Load module for reading and writing raw-files and json-files.
-- Details: https://realtimelogic.com/ba/doc/?url=Mako.html#rwfile
local rw=require"rwfile"

-- Convert to closures so variables work in the cmsfunc() callback function
-- Closure def: https://en.wikipedia.org/wiki/Closure_(computer_programming)
local app,io,dir=app,app.io,dir


-- Takes a file name as argument, reads the full content, converts the
-- LSP page (HTML with LSP tags) to Lua code, and compiles the Lua
-- code. The compiled Lua code is returned as a function.
-- Details: https://realtimelogic.com/ba/doc/?url=lua.html#ba_parselsp
local function parseLspPage(name)
   local func
   local data,err=rw.file(io,name) -- Read file content
   if data then
      data,err = ba.parselsp(data)
      if data then
         local func
         -- Compile Lua code
         -- ref load: https://realtimelogic.com/ba/doc/luaref_index.html?url=pdf-load
         func,err = load(data,name,"t")
         if func then return func end
      end
   end
   -- Failed
   trace(fmt("parsing %s failed: %s",name,err))
   return function(_ENV) print(name,err) end
end

-- Parse and cache the template page.
local templatePage=parseLspPage(".lua/www/template.lsp")

-- Load the JSON encoded menu
local menuL=rw.json(io,".lua/menu.json")
assert(menuL, "lua/menu.json parse error")

-- We need to keep track of the parent-child relationship in a
-- multi-level menu system when dynamically building the menu in
-- template.lsp. The parent(s) of the active menu item must have the
-- CSS class 'menu-open' for them to automatically expand. parentRefT
-- is a table where the key is the relative path (URL path component)
-- and the value is a table where the key is a parent menu item
-- (table) and the value is boolean true. The parentRefT is used in
-- template.lsp when building the menu. parentRefT is initialized by
-- function buildRef() below.
local parentRefT={}

-- The breadcrumb shown in the top right corner enables easy
-- navigation from child to parent. The breadcrumb is dynamically
-- created in template.lsp. breadcrumbT is a table where the key is
-- the relative path and the value is a list of all parents. Each
-- element in this list is a table with {name,href}
local breadcrumbT={}

-- This function is called for each element in the menu list (menuL
-- loaded from menu.json). The function builds the relations needed by
-- template.lsp. The function populates the two tables parentRefT and
-- breadcrumbT declared above. This function is recursively called for
-- each sub-menu component.
 -- Args:
--   m: one menu item from the parent list.
--   parentsT: key/val table, where the key is set to the parent and
--      the value is set to boolean true. The leaf node sets
--      parentRefT[m.href]=parentsT
--   breadcrumbL: a list of all parents. Each parent is added to the
--     list when buildRef is called recursively.  The leaf node sets
--     breadcrumbT[m.href]=breadcrumb if the list is not empty.
local function buildRef(m,parentsT,breadcrumbL)
   if m.sub then
      parentsT[m.sub]=true
      table.insert(breadcrumbL,{name = m.name, href = m.href and m.href ~= '#' and m.href})
      for _,ms in ipairs(m.sub) do
         buildRef(ms,parentsT,breadcrumbL)
      end
   elseif m.href and #m.href > 0 and #m.href ~= '#' then
      parentRefT[m.href]=parentsT
      if #breadcrumbL > 0 then breadcrumbT[m.href]=breadcrumbL end
   end
   -- Page specific JavaScript code: set m.js = file name if this page has JavaScript code.
   if  m.href and m.href ~= '#' then
      local jsname=fmt(".lua/www/%s.js",m.href:match"(.-)%.[^%.]+$")
      if io:stat(jsname) then
         m.js=jsname
      end
   end
end

-- Populate parentRefT and breadcrumbT
for _,m in ipairs(menuL) do
   buildRef(m,{},{})
end


-- An LSP page expects a persistent table unique to each page. The
-- pagesT is a table where the key is the relative path and the value
-- is the LSP page's unique table.
-- Details: https://realtimelogic.com/ba/doc/?url=lua.html#CMDE
local pagesT={}

-- The directory callback function. This callback is called by the
-- server when a resource is accessed. Argument env is the
-- request/response environment table and relpath is the relative path.
-- See the following for details on the request/response environment:
-- https://realtimelogic.com/ba/doc/?url=lua.html#CMDE
local function cmsfunc(_ENV,relpath)

   -- Translate to (path/)index.html if only directory name is provided.
   if #relpath == 0 or relpath:find"/$" then
      relpath = relpath.."index.html"
   end

   -- Table parentRefT includes all known pages (the key) and a table
   -- lookup results in nil if the requested page does not exist. Set
   -- the relative path to the 404 page if not found.
   if not parentRefT[relpath] then
      response:setstatus(404)
      relpath = "pages/examples/404.html"
   end
   
   -- Fetch the LSP page's persistent page table. Create the table if
   -- the page has so far not been accessed.
   local pageT=pagesT[relpath]
   if not pageT then
      pageT={}
      pagesT[relpath]=pageT
   end

   -- Make the following available to template.lsp
   -- Note, we explicitly use the _ENV tab for readability.
   _ENV.parentRefT=parentRefT
   _ENV.breadcrumbT=breadcrumbT
   _ENV.menuL=menuL
   _ENV.relpath=relpath
   -- lspPage is the parsed page (function as explained in parseLspPage above)
   _ENV.lspPage=parseLspPage(".lua/www/"..relpath)
   -- Call the template page and pass in the required arguments.
   -- Arg details: https://realtimelogic.com/ba/doc/?url=lua.html#ba_parselsp
   templatePage(_ENV,relpath,io,pageT,app)
   -- non cached version of above. Use if testing new template.
   --parseLspPage(".lua/www/template.lsp")(_ENV,relpath,io,pageT,app)
   return true
end

-- Create the directory function used by our mini CMS system and
-- install the callback function. A directory with no name is in
-- effect a sibling when installed as a sub-directory. The following
-- construction makes sure we do not trigger the callback for any
-- static assets. In other words, static assets takes precedence. The
-- callback is called when no static asset is found.
-- Ref dir: https://realtimelogic.com/ba/doc/?url=lua.html#ba_create_dir
local cmsdir = ba.create.dir()
cmsdir:setfunc(cmsfunc)
-- All applications have a predefined 'dir' object, which is an resrdr instance.
-- Insert the cmsdir as a sibling.
-- Ref resrdr: https://realtimelogic.com/ba/doc/?url=lua.html#ba_create_resrdr
dir:insert(cmsdir,true)
