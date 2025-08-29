-- rest.lua
-- Minimal REST-style router for BAS

local M = {}
M.__index = M

-- Normalize method(s) into uppercase list
local function normalizeMethods(method)
   if type(method) == "string" then
      return { string.upper(method) }
   elseif type(method) == "table" then
      local t = {}
      for _, m in ipairs(method) do
         t[#t+1] = string.upper(m)
      end
      return t
   else
      error("method must be string or table",3)
   end
end

-- Strip leading slash (since BAS relative paths have none)
local function normalizePattern(pat)
   if pat:sub(1,1) == "/" then
      return pat:sub(2)
   end
   return pat
end

-- Register a route
function M:route(method, pat, callback)
   local methods = normalizeMethods(method)
   pat = normalizePattern(pat)
   -- wildcard if ends with "*"
   local isWildcard = pat:sub(-1) == "*"
   if isWildcard then
      local prefix = pat:sub(1, -2) -- drop the '*'
      for _, m in ipairs(methods) do
         self.wildcard[m] = self.wildcard[m] or {}
         table.insert(self.wildcard[m], { prefix, callback })
      end
   else
      for _, m in ipairs(methods) do
         self.exact[m] = self.exact[m] or {}
         self.exact[m][pat] = callback
      end
   end
end

-- Internal dispatcher called by VFS
local function dispatch(self, env, relPath)
   local m = env.request:method()
   local path = relPath or ""  -- BAS gives "" for directory root
   -- 1. Try exact
   local exact = self.exact[m]
   if exact and exact[path] then
      if exact[path](env, path, m) ~= false then return true end
   end
   -- 2. Try wildcard
   local wc = self.wildcard[m]
   if wc then
      for _, entry in ipairs(wc) do
         local prefix, cb = entry[1], entry[2]
         if path:find(prefix, 1, true) == 1 then
            if cb(env, path, m) ~= false then return true end
         end
      end
   end
   return false -- no match, let VFS continue
end

-- Install router into VFS
function M:install(name, parent)
   if self.dir then error("Already installed",2) end
   local dir = ba.create.dir(name)
   self.dir=dir
   dir:setfunc(function(env, relPath) return dispatch(self, env, relPath) end)
   if parent then
      parent:insert(dir)
   else
      dir:insert() -- Insert as root
   end
   return dir
end

function M:unlink()
   if not self.dir then error("Not installed",2) end
   self.dir:unlink()
   self.dir=nil
end

-- Constructor
return {
   create=function()
      return setmetatable({
         exact = {},      -- exact[method][path] = callback
         wildcard = {},   -- wildcard[method] = { {prefix, callback}, ... }
      }, M)
   end
}

