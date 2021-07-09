
-- Mini Content Management System (CMS) designed for the Pure.css dashboard.

local fmt=string.format

-- Load module for reading and writing raw-files and json-files.
-- Details: https://realtimelogic.com/ba/doc/?url=Mako.html#rwfile
local rw=require"rwfile"

-- Convert to closures so variables work in the cmsfunc() callback function
-- Closure def: https://en.wikipedia.org/wiki/Closure_(computer_programming)
local app,io,dir=app,app.io,dir


-- Takes the data content of an LSP page (HTML with LSP tags) as
-- argument, converts the LSP page to Lua code, and compiles the Lua
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
-- Details: https://realtimelogic.com/ba/doc/?url=lua.html#CMDE
local pagesT={}

-- The directory callback function. This callback is called by the
-- server when a resource is accessed. Argument env is the
-- request/response environment table and relpath is the relative path.
-- See the following for details on the request/response environment:
-- https://realtimelogic.com/ba/doc/?url=lua.html#CMDE
local function cmsfunc(_ENV, relpath, notInMenuOK)

   -- Translate to (path/)index.html if only directory name is provided.
   if #relpath == 0 or relpath:find"/$" then
      relpath = relpath.."index.html"
   end

   -- Do we have the requested page (must be in file menu.json)
   if not menuT[relpath] and not notInMenuOK then
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

   -- Make the following available to template.lsp
   -- Note, we explicitly use the _ENV tab for code readability.
   -- Details: https://realtimelogic.com/ba/doc/en/lua/man/manual.html#2.2
   --          https://realtimelogic.com/ba/doc/?url=lua.html#CMDE
   _ENV.menuL=menuL
   _ENV.menuT=menuT
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
-- static assets. In other words, static assets take precedence. The
-- callback is called when no static asset is found.
-- Ref dir: https://realtimelogic.com/ba/doc/?url=lua.html#ba_create_dir
local cmsdir = ba.create.dir()
cmsdir:setfunc(cmsfunc)


------------------- AUTHENTICATION ---------------------------------
-- All code below is for setting up authentication and authorization

-- Default realm used by the server (can be changed).
local realm = "Barracuda Server"

-- HA1 = MD5(username ":" realm ":" password)
-- https://realtimelogic.com/ba/doc/en/lua/auth.html
local function ha1(realm,username,password)
   return ba.crypto.hash"md5"(username)":"(realm)":"(password)(true,"hex")
end


-- Hard coded user database, with the following users: admin,user
-- All users have the same password: qwerty
local userdb = {
   user={ pwd={ha1(realm, "user", "qwerty")}, roles={"user"} },
   admin={ pwd={ha1(realm, "admin", "qwerty")}, roles={"admin"} },
}

-- Hard coded constraints
local constraints = {
   user={
      urls={'/*'},
      methods={'GET'},
      roles={'user'}
   },
   admin={
      urls={'/*'},
      methods={'GET','POST'},
      roles={'admin'}
   },
}

-- JSON User Database: https://realtimelogic.com/ba/doc/?url=lua.html#ba_create_jsonuser
local ju=ba.create.jsonuser()
assert(ju:set(userdb)) -- Insert JSON string or Lua table (We use Lua table)
local ja=ju:authorizer()
assert(ja:set(constraints)) -- Insert JSON string or Lua table (We use Lua table)

-- ba.create.authenticator() callback function
local function loginresponse(_ENV, authinfo)
   -- How _ENV is used: https://realtimelogic.com/ba/doc/?url=lua.html#CMDE
   _ENV.authinfo = authinfo -- Makes it possible for .login-form.lsp to use authinfo
   authinfo.realm=realm -- Used by login.lsp
   -- The following prints the content of the authinfo table
   trace("loginresponse", ba.json.encode(authinfo))
   cmsfunc(_ENV,"login.html", true) -- Let the CMS function emit the login page.
end

-- Create the authenticator that will be applied to the 'pages' directory.
local authenticator=ba.create.authenticator(ju,{response=loginresponse, type="form", realm=realm})
local authDir = ba.create.dir(1) -- No name matches "", set priority to a value greater than cmsdir.
authDir:setauth(authenticator,ja)
authDir:p403("/.lua/www/no-access.lsp")

-- All applications have a predefined 'dir' object, which is a resrdr instance.
-- Ref resrdr: https://realtimelogic.com/ba/doc/?url=lua.html#ba_create_resrdr
-- Insert authDir and cmsdir as siblings.
dir:insert(authDir,true)
dir:insert(cmsdir,true)

