-- GitHubIo.lua; ChatGPT generated with manual fixes and improvements.
-- GitHub-backed LuaIo for BAS: https://realtimelogic.com/ba/doc/en/lua/auxlua.html#luaio
-- Re-entrant (no shared httpc), directory-aware, recursive delete, mtime = 1759270202

local mtime=1759270202
local json,sfind = ba.json,string.find
local dirMeta={ mtime = mtime, size = 0, isdir = true }
local function strip(path) return path:gsub("^/",""):gsub("/+$","") end

local function readAPI(buf)
   local offset = 0
   local function read(maxsize)
      if not maxsize or maxsize == "a" then
	 local out = buf:sub(offset + 1)
	 offset = #buf
	 return out
      end
      local to	= math.min(#buf, offset + maxsize)
      local out = buf:sub(offset + 1, to)
      offset = to
      return out
   end
   local function seek(off) if off < 0 or off > #buf then return nil end; offset = off; return true end
   return {
      read = read,
      write = function() return nil end,
      seek = seek,
      flush = function() return true end,
      close = function() return true end
   }
end


local function create(op)
   local mtime = "number" == type(op.mtime) and op.mtime or mtime
   assert(op and op.owner and op.repo and op.token, "owner/repo/token required")
   local log=op.log and ("function" == type(op.log) and
			 op.log or function(u,c,m) tracep(false,1,"GitHubIo:",u,c,m) end)
      or function() end
   local lockdir,fCache,hCache=op.lockdir or ".LOCK",{},nil
   local api	= op.api or "https://api.github.com"
   local branch = op.branch or "main"
   local base	= api .. "/repos/" .. op.owner .. "/" .. op.repo .. "/contents/"

   ---------- HTTP helper (per-request client) --------

   local function hCreate()
      if hCache then
	 local httpc=hCache
	 hCache=nil
	 return httpc
      end
      return require("httpc").create()
   end

   local function hClose(httpc)
      httpc:close()
      if not hCache then hCache=httpc end
   end

   -- WebDAV meta data cache
   local function cachable(name)
      name=name:gsub("^/","")
      return 1 == sfind(name,lockdir,1,true) or sfind(name,".DAV",1,true) and true or false
   end

   local function urlFor(path)
      return base .. strip(path)
   end

   local function ghReq(method, url, hdr, bodyStr, query)
      local httpc = hCreate()
      local header = {
	 ["Authorization"] = "Bearer " .. op.token,
	 ["Accept"]	   = "application/vnd.github+json",
	 ["User-Agent"]	   = "BAS-LuaIo/1.3",
      }
      if hdr then for k,v in pairs(hdr) do header[k] = v end end
      local req = { url = url, method = method, header = header }
      if query then req.query = query end
      if bodyStr then req.size = #bodyStr end
      local ok, err = httpc:request(req)
      if not ok then return nil, err end
      if bodyStr then
	 local ok, err = httpc:write(bodyStr)
	 if not ok then return nil, err end
      end
      local body = httpc:read("a") or ""
      local code = httpc:status()
      local header=httpc:header()
      hClose(httpc)
      if 200 ~= code then
	 local r=json.decode(body)
	 log(url,code,r and r.message or "")
      end
      return code, body, header
   end

   -- Raw-by-path (respects branch/path protections)
   local function ghGetRawByPath(path, ref)
      local httpc = hCreate()
      local ok = httpc:request{
	 url	= urlFor(path),
	 method = "GET",
	 header = {
	    ["Authorization"] = "Bearer " .. op.token,
	    ["Accept"]	      = "application/vnd.github.raw",
	    ["User-Agent"]    = "BAS-LuaIo/1.3",
	 },
	 query	= ref and { ref = ref } or nil,
      }
      if not ok then return nil, "noaccess" end
      local body = httpc:read("a") or ""
      local status=httpc:status()
      hClose(httpc)
      return (status == 200) and body or nil, "noaccess"
   end

   -- Raw-by-blob SHA (great for large files too)
   local function ghGetBlobRaw(sha)
      local httpc = hCreate()
      local ok = httpc:request{
	 url	= api .. "/repos/" .. op.owner .. "/" .. op.repo .. "/git/blobs/" .. sha,
	 method = "GET",
	 header = {
	    ["Authorization"] = "Bearer " .. op.token,
	    ["Accept"]	      = "application/vnd.github.raw",
	    ["User-Agent"]    = "BAS-LuaIo/1.3",
	 }
      }
      if not ok then return nil, "noaccess" end
      local body = httpc:read("a") or ""
      local status=httpc:status()
      hClose(httpc)
      return (status == 200) and body or nil, "noaccess"
   end

   -- -------- GitHub Contents helpers --------
   local function ghGetMeta(path, ref)
      local code, body = ghReq("GET", urlFor(path), nil, nil, ref and { ref = ref } or nil)
      if code == 200 then
	 return json.decode(body)
      elseif code == 404 then
	 return nil, "enoent"
      else
	 return nil, "notfound"
      end
   end

   local function ghPutFile(path, b64content, message, sha)
      local payload = {
	 message = message,
	 content = b64content,
	 branch	 = branch,
      }
      if sha then payload.sha = sha end
      local code, body = ghReq(
	 "PUT", urlFor(path),
	 { ["Content-Type"] = "application/json" },
	 json.encode(payload)
      )
      if code == 200 or code == 201 then
	 return json.decode(body)
      elseif code == 409 then
	 return nil, "exist"
      else
	 return nil, "noaccess"
      end
   end

   local function ghDeleteNode(path, sha, message)
      local payload = { message = message, sha = sha, branch = branch }
      local code,err = ghReq(
	 "DELETE", urlFor(path),
	 { ["Content-Type"] = "application/json" },
	 json.encode(payload)
      )
      if code == 200 then
	 return true
      elseif code == 404 then
	 return nil, "enoent"
      else
	 return nil, "noaccess"
      end
   end

   -- Directory detection
   local function isArray(t)
      return type(t) == "table" and t[1] ~= nil and t.type == nil
   end

   -- -------- LuaIo callbacks --------
   local function stat(name)
      name=strip(name)
      if name==lockdir then return dirMeta end
      local m=fCache[name]
      if m then return m end
      local node, err = ghGetMeta(name, branch)
      if not node then return nil, err end
      if node.type == "file" then return { mtime = mtime, size = node.size, isdir = false } end
      return dirMeta
   end

   local function files(name)
      local list, err = ghGetMeta(name, branch)
      if not list then return nil, err end
      if list.type == "file" then return nil, "noaccess" end
      local i = 0
      local function it_read()
	 i = i + 1
	 if i <= #list and list[i].name == ".keep" then i = i + 1 end
	 return i <= #list
      end
      local function it_name() return list[i] and list[i].name or nil end
      local function it_stat()
	 local n = list[i]
	 if not n then return nil end
	 return { mtime = mtime, size = tonumber(n.size or 0), isdir = (n.type == "dir") }
      end
      return { read = it_read, name = it_name, stat = it_stat }
   end

   local function mkdir(name)
      name=strip(name)
      if cachable(name) then return true end
      local keepPath = strip(name) .. "/.keep"
      local ok, err = ghPutFile(
	 keepPath,
	 ba.b64encode(""),
	 ("ci: mkdir %s"):format(name)
      )
      return ok and true or nil, err
   end

   local function deletePath(path)
      local node, err = ghGetMeta(path, branch)
      if not node then return nil, err end

      if node.type == "file" then
	 return ghDeleteNode(path, node.sha, ("ci: delete %s"):format(path))
      end
      local code, body = ghReq("GET", urlFor(path), nil, nil, { ref = branch })
      if code ~= 200 then return nil, "noaccess" end
      for _, entry in ipairs(node) do
	 local p = strip(path) .. "/" .. entry.name
	 local ok2, e2 = deletePath(p)
	 if not ok2 then return nil, e2 end
      end
      return true
   end

   local function rmdir(name)
      local ok, err = deletePath(name)
      if ok then return true end
      if err == "enoent" then return nil, "enoent" end
      return nil, err
   end

   local function remove(name)
      name=strip(name)
      if fCache[name] then
	 fCache[name]=nil
	 return true
      end
      local node, err = ghGetMeta(name, branch)
      if not node then return nil, err end
      if node.type ~= "file" then return nil, "invalidname" end
      return ghDeleteNode(name, node.sha, ("ci: delete %s"):format(name))
   end

   local function open(name, mode)
      name=strip(name)
      mode = mode or "r"
      local node = ghGetMeta(name, branch)
      if mode == "r" then
	 local m=fCache[name]
	 if m then return readAPI(m.payload) end
	 if not node or node.type ~= "file" then return nil, "enoent" end
	 local content = ghGetRawByPath(name, branch)
	 if not content then
	    content = ghGetBlobRaw(node.sha)
	    if not content then return nil, "noaccess" end
	 end
	 return readAPI(content)
      elseif mode == "w" then
	 if cachable(name) then
	    local t={}
	    return {
	       read = function() return nil end,
	       write = function(buf) table.insert(t,buf) return true end,
	       seek = function() return nil, "noaccess" end,
	       flush = function() return true end,
	       close = function()
		  t={payload=table.concat(t),isdir=false,mtime=mtime}
		  t.size=#t.payload
		  fCache[name]=t
		  return true
	       end
	    }
	 end
	 local currentSha = node and node.sha or nil
	 local writeBuf = {}
	 local function write(data) writeBuf[#writeBuf+1] = data return true end
	 local function doUpload()
	    local b64 = ba.b64encode(table.concat(writeBuf))
	    local ok, err = ghPutFile(
	       name, b64,
	       currentSha and ("ci: update %s"):format(name) or ("ci: create %s"):format(name),
	       currentSha
	    )
	    if not ok then return nil, err end
	    currentSha = ok.content and ok.content.sha or currentSha
	    return true
	 end
	 return {
	    read = function() return nil end,
	    write = write,
	    seek = function() return nil, "noaccess" end,
	    flush = function() return true end,
	    close = function() return doUpload() end
	 }
      else
	 return nil, "invalidname"
      end
   end

   return ba.create.luaio{
      open   = open,
      files  = files,
      stat   = stat,
      mkdir  = mkdir,
      rmdir  = rmdir,
      remove = remove,
   }
end

return { create = create }
