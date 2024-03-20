--NGX interface required for OpenResty's DB libs: mysql and redis

local sock=require"socket.core"

local vOK=ba.version() >= 5521

local function sockTcp()
   if not vOK then return nil,"Upgrade BAS: server too old" end
   local s = sock.tcp()
   if not s.setkeepalive then
      local function setkeepalive(self)
         self:close()
         return true
      end
      local t = getmetatable(s).__index
      t.setkeepalive=setkeepalive
      t.getreusedtimes = function() return 0 end
   end
   return s
end

_G.ngx={
   config={
      ngx_lua_version=9011
   },
   sha1_bin=function(data)
               return ba.crypto.hash"sha1"(data)(true)
            end,
   socket={tcp=sockTcp},
   say=print,
   log=function(x,...) trace(...) end
}

-- End  NGX interface

return _ENV
