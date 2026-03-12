local h2n,n2h=ba.socket.h2n,ba.socket.n2h
local tinsert,tconcat=table.insert,table.concat

local function notImpl() error("not implemented",3) end
local function notRead() error("not opened for reading",3) end
local function notWrite() error("not opened for writing",3) end

local function closeOnErr(self,err)
   self.close()
   return nil, (err or "ioerror")
end

local function estat(fp,st,err,noClose)
   if fp and st then
      if st.size >= 8 then
	 fp:seek(st.size-8)
	 local data=fp:read(8)
	 if data and 8==#data then
	    local size,negSize=n2h(4,data),n2h(4,data,5)
	    -- Convert two's-complement 32-bit negated size back to
	    -- positive (Ref-S)
	    negSize=(-negSize) % 0x100000000
	    if size == negSize then
	       st.size=size
	       if noClose then
		  fp:seek(0)
	       else
		  fp:close()
	       end
	       return st
	    end
	 end
      end
      err="enoent"
   end
   if fp then fp:close() end
   return nil,(err or "ioerror")
end

local function read(self,size)
   if not self.fp then return nil,"closed" end
   local buffer=self.buffer
   self.buffer=nil
   local bsize=buffer and #buffer or 0
   if self.rwsize==self.size and 0==bsize then return nil end -- eof
   if bsize < size then
      local size2=size
      local bufT={buffer}
      while size2 > 0 and self.rwsize~=self.size do
	 local blocksize=self.blocksize
	 local tag,err=self.fp:read(16)
	 if not tag then return closeOnErr(self,err) end
	 local rem=self.size-self.rwsize
	 local data,err=self.fp:read(rem > blocksize and blocksize or rem)
	 if not data then return closeOnErr(self,err) end
	 self.rwsize=self.rwsize+#data
	 if #data < blocksize then
	    assert(self.rwsize==self.size)
	    size2=0 -- break
	 end
	 data=self.s:decrypt(data,tag)
	 if not data then return closeOnErr(self,"enoent") end
	 tinsert(bufT,data)
	 size2=size2-#data
      end
      buffer=tconcat(bufT)
   end
   if #buffer > size then
      local chunk = buffer:sub(1, size)
      self.buffer=buffer:sub(size + 1)
      return chunk
   end
   return buffer
end

local function write(self,data)
   if not self.fp then return nil,"closed" end
   local buffer=self.buffer
   if buffer then data=buffer..data end
   local blocksize=self.blocksize
   if #data < blocksize then
      self.buffer=data
      return true
   end
   while #data >= blocksize do
      local cipher,tag = self.s:encrypt(data:sub(1,blocksize))
      local ok,err=self.fp:write(tag)
      if ok then ok,err=self.fp:write(cipher) end
      if not ok then return closeOnErr(self,err) end
      data=data:sub(blocksize + 1)
      self.rwsize=self.rwsize+blocksize
   end
   self.buffer = #data > 0  and data
   return true
end

local function rclose(self)
   self.rwsize=self.size -- eof
   if self.fp then
      self.fp:close()
      self.fp=nil
      return true
   end
   return nil,"closed"
end

local function wclose(self)
   if self.fp then
      local fp=self.fp
      local buffer=self.buffer
      local ok,err=true
      if buffer then
	 self.buffer=nil
	 local cipher,tag=self.s:encrypt(buffer)
	 ok,err=fp:write(tag)
	 if ok then ok,err=fp:write(cipher) end
      end
      if ok then
	 local rwsize=self.rwsize+(buffer and #buffer or 0)
	 ok,err=fp:write(h2n(4,rwsize)..h2n(4,-rwsize)) -- Ref-S
      end
      fp:close()
      self.fp=nil
      return ok,err
   end
   return nil,"closed"
end

local function open(io,key,op,name,mode)
   if "r"~=mode and "w"~=mode then error("mode must be 'r' or 'w'",3) end
   local fp,err,st,self,xread,xwrite,xflush,xclose,iv,ok
   fp,err=io:open(name,mode)
   if not fp then return nil,err end
   if "w"==mode then
      xread,xwrite=notRead,write
      xflush,xclose=function() return fp:flush() end,function() return wclose(self) end
      st={}
      iv=ba.rndbs(12)
      ok=fp:write(iv)
   else
      xread,xwrite=read,notWrite
      xflush,xclose=notWrite,function() return rclose(self) end
      st,err=io:stat(name)
      st,err=estat(fp,st,err,true)
      if not st then return nil,err end
      iv=fp:read(12)
      ok=iv and 12==#iv
   end
   local s=ok and ba.crypto.symmetric("GCM",key,iv)
   if not s then return nil,(err or "ioerror") end
   if op.auth then s:setauth(op.auth) end
   self={blocksize=op.size,size=st.size,rwsize=0,fp=fp,s=s,close=xclose}
   return {
      read=function(size) return xread(self,size) end,
      write=function(data) return xwrite(self,data) end,
      flush=xflush,
      close=xclose,
      seek=notImpl
   }
end

local function files(io,name)
   local iter,err=io:files(name,true)
   if not iter then return nil,err end
   local path=name:match("^(.*[/\\])") or ""
   local name,isdir,mtime,size
   return {
      read=function()
	 repeat	 
	    name,isdir,mtime,size=iter()
	 until name ~= "." and name ~= ".."
	 return name and true or false
      end,
      stat=function()
	 local st={mtime=mtime,size=size,isdir=isdir}
	 if st.isdir then return st end
	 return estat(io:open(path..name),st)
      end,
      name=function() return name end,
   }
end

local function create(io,keyname,op)
   if "userdata"~=type(io) then error("io required",2) end
   if "string"~=type(keyname) or #keyname == 0 then error("keyname required",2) end
   op=op or {}
   op.size=op.size or 1024
   if op.size < 16 or 0 ~= op.size % 16 or op.size>0xFFF0 then error("Invalid op.size",2) end
   local key=ba.crypto.hash"sha256"(ba.tpm.uniquekey(keyname,32))(true)
   return ba.create.luaio{
      open=function(name,mode) return open(io,key,op,name,mode) end,
      files=function(name) return files(io,name) end,
      stat=function(name)
	 local st,err=io:stat(name)
	 if not st then return nil,err end
	 if st.isdir then return st end
	      return estat(io:open(name),st)
	   end,
      mkdir=function(name) return io:mkdir(name) end,
      rmdir=function(name) return io:rmdir(name) end,
      remove=function(name) return io:remove(name) end
   }
end

return create
