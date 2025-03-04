-- Mini Content Management System (CMS) designed for the Pure.css dashboard.

-- All LSP applications have a predefined 'dir' object, which is a resrdr instance.
-- Ref resrdr: https://realtimelogic.com/ba/doc/en/lua/lua.html#ba_create_resrdr
-- The dir object is not set when running as an Xedge xlua app (not LSP enabled app)
-- https://realtimelogic.com/ba/doc/en/Xedge.html#using
if not dir then
   error"This application must run as an LSP enabled app"
end

local fmt=string.format

-- Load module for reading and writing raw-files and json-files.
-- Details: https://realtimelogic.com/ba/doc/en/lua/auxlua.html#rwfile
local rw=require"rwfile"

-- Convert to closures so variables work in the cmsfunc() callback function
-- Closure def: https://en.wikipedia.org/wiki/Closure_(computer_programming)
local app,io,dir=app,app.io,app.dir

-- Set on 'dir' and used by function cmsfunc()
local securityPolicies={
   ["Content-Security-Policy"]= "default-src 'self'; script-src 'self' cdn.jsdelivr.net unpkg.com 'unsafe-inline'; style-src 'self' cdn.jsdelivr.net unpkg.com 'unsafe-inline'",
   ["X-Content-Type-Options"]="nosniff",
}
-- Doc: https://realtimelogic.com/ba/doc/en/lua/lua.html#rsrdr_header
dir:header(securityPolicies)

-- Takes the data content of an LSP page (HTML with LSP tags) as
-- argument, converts the LSP page to Lua code, and compiles the Lua
-- code. The compiled Lua code is returned as a function.
-- Details: https://realtimelogic.com/ba/doc/en/lua/lua.html#ba_parselsp
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
   err = fmt("parsing or running %s failed: %s",name,err)
   trace(err)
   return function(_ENV) print(err) end
end

-- Parse and cache the template page.
local templatePage=parseLspPage(".lua/www/template.lsp")


-- Load the JSON encoded menu
local menuL=rw.json(io,".lua/menu.json")
assert(menuL, "lua/menu.json parse error")

--Create a key/value version of the menu list, where key is the relative path name 'href'.
local menuT={}
for _,m in ipairs(menuL) do
   menuT[m.href]=m
end

-- An LSP page expects a persistent table unique to each page. The
-- pagesT is a table where the key is the relative path and the value
-- is the LSP page's unique table.
-- Details: https://realtimelogic.com/ba/doc/en/lua/lua.html#CMDE
local pagesT={}

-- The directory callback function. This callback is called by the
-- server when a resource is accessed. Argument env is the
-- request/response environment table and relpath is the relative path.
-- See the following for details on the request/response environment:
-- https://realtimelogic.com/ba/doc/en/lua/lua.html#CMDE
local function cmsfunc(_ENV, relpath, notInMenuOK)
   trace("hx-request:",request:header"hx-request" and "yes" or "no")
   local response=response -- e.g. = _ENV.response. Now faster.

   -- Translate to (path/)index.html if only directory name is provided.
   if #relpath == 0 or relpath:find"/$" then
      relpath = relpath.."index.html"
   end

   -- Do we have the requested page (must be in file menu.json)
   if not menuT[relpath] and not notInMenuOK then
      if not relpath:find(".html",-5,true) then
         return false -- Not a html page. Let default 404 handle this
      end
      trace("Not found",relpath) -- For debug purposes
      response:setstatus(404)
      relpath = "404.html"
   end

   -- Fetch the LSP page's persistent page table. Create the table if
   -- the page has so far not been accessed.
   local pageT=pagesT[relpath]
   if not pageT then
      pageT={}
      pagesT[relpath]=pageT
   end

   --Remove the following line and xrsp:finalize() if you do not want to
   --compress the response.
   local xrsp <close> = response:setresponse() -- Activate compression
   response:setdefaultheaders()

   local lspPage=parseLspPage(".lua/www/"..relpath)
   if request:header"hx-request" then
      lspPage(_ENV,relpath,io,pageT,app)
   else
      for k,v in pairs(securityPolicies) do response:setheader(k,v) end
      -- Make the following available to template.lsp
      -- Note, we explicitly use the _ENV tab for code readability.
      -- Details: https://realtimelogic.com/ba/doc/en/lua/man/manual.html#2.2
      --          https://realtimelogic.com/ba/doc/en/lua/lua.html#CMDE
      _ENV.menuL=menuL
      _ENV.menuT=menuT
      _ENV.relpath=relpath
      -- lspPage is the parsed page (function as explained in parseLspPage above)
      _ENV.lspPage=lspPage
      -- Call the template page and pass in the required arguments.
      -- Arg details: https://realtimelogic.com/ba/doc/en/lua/lua.html#ba_parselsp
      templatePage(_ENV,relpath,io,pageT,app)
      -- non cached version of above. Use if testing new template.
      --parseLspPage(".lua/www/template.lsp")(_ENV,relpath,io,pageT,app)
   end
   xrsp:finalize(true) -- Send compressed data to client

   return true
end

-- Create the directory function used by our mini CMS system and
-- install the callback function. A directory with no name is in
-- effect a sibling when installed as a sub-directory. The following
-- construction makes sure we do not trigger the callback for any
-- static assets. In other words, static assets take precedence. The
-- callback is called when no static asset is found.
-- Ref dir: https://realtimelogic.com/ba/doc/en/lua/lua.html#ba_create_dir
local cmsDir = ba.create.dir()
cmsDir:setfunc(cmsfunc)


-- Insert cmsDir as 'dir' siblings. This means the parent will be
-- searched first. The parent resource reader (dir) manages the static
-- content. See www/static for content returned to browser
dir:insert(cmsDir,true)



----------------------- AUTHENTICATION -----------------------------

if ba.tpm then
   -- The following code is based on example from:
   -- https://realtimelogic.com/ba/doc/en/lua/auxlua.html#TPM

   local cfgio = ba.openio"home" or ba.openio"disk" -- mako or xedge
   local rw=require"rwfile"

   -- Read/write encrypted db. Write if 'encdb' provided
   local function rwdb(encdb)
      trace(encdb and "Writing" or "Reading","userdb.encrypted")
      return rw.file(cfgio,"userdb.encrypted",encdb)
   end

   -- ba.create.authenticator() callback function
   local function loginresponse(_ENV, authinfo)
      -- How _ENV is used: https://realtimelogic.com/ba/doc/en/lua/lua.html#CMDE
      _ENV.authinfo = authinfo -- Makes it possible for .login-form.lsp to use authinfo
      -- The following prints the content of the authinfo table
      trace("loginresponse", ba.json.encode(authinfo))
      cmsfunc(_ENV,"login.html", true) -- Let the CMS function emit the login page.
   end

   -- Create the wrapper and make the encrypted DB global
   local tju=ba.tpm.jsonuser("dashboard",true)

   local authDir=nil
   local function setOrRemoveAuth()
      if #tju.users() > 0 and not authDir then -- SET
         authDir = ba.create.dir(1) -- Set priority to a value greater than cmsDir.
         local authenticator=ba.create.authenticator(tju.getauth(),{response=loginresponse, type="form"})
         authDir:setauth(authenticator)
         dir:insert(authDir,true) -- Higher prio than cmsDir thus executes before 
         trace"Installing authenticator"
      elseif #tju.users() == 0 and authDir then -- REMOVE
         authDir:unlink() -- Remove authenticator
         authDir=nil
         trace"Removing authenticator"
      end
   end

   function setuser(name,pwd) -- Used by www/.lua/www/Users.html 
      rwdb(tju.setuser(name,pwd))
      setOrRemoveAuth()
   end
 
   local encdb=rwdb() -- Load the encryted DB, if any
   if encdb then
      -- Set the DB
      local ok,err=tju.setdb(encdb)
      if ok then
         setOrRemoveAuth()
      else
         trace("Authenticator not installed; User DB error:",err)
      end
   else
      trace"No user database; Authenticator not installed"
   end
else
   trace"No TPM. Authenticator not installed"
end

-- Return onunload handler
return function() end -- Not used
