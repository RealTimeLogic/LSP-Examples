local pcall,fmt,tpack,tunpack=pcall,string.format,table.pack,table.unpack

local function create(smq,intf)
   local function onRpcReq(pl,ptid)
      local f=intf[pl.name] or function() return nil,fmt("RPC function %s not found", pl.name or "?") end
      local ok,rsp,err = pcall(f, tunpack(pl.args))
      if not ok then err=rsp rsp=nil end
      if rsp then err=nil end
      smq:publish({id=pl.id,rsp=rsp,err=err}, ptid, "$RpcResp")
   end
   return smq:subscribe("self",{subtopic="$RpcReq", json=true, onmsg=onRpcReq})
end

return {create=create}
