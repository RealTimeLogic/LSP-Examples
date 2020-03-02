<?lsp

-- Basic math lib for adding and subtracting.
local math={}
function math.add(a,b) return a + b end
function math.subtract(a,b) return a - b end

-- The AJAX API we expose to the client
local rpc={
   math=math,
   os=os -- Lua 'os' lib: https://realtimelogic.com/ba/doc/luaref_index.html?url=manual.html#6.9
}

-- Socket intro: https://realtimelogic.com/ba/doc/?url=SockLib.html

-- AJAX WebSocket server side service
local function service(sock)
   while true do -- Loop and parse AJAX requests
      local req=sock:read() -- Wait for next AJAX request
      if not req then break end -- Socket closed
      req=ba.json.decode(req) -- Convert JSON to Lua object
      local func -- The function requested by the client
      pcall(function() -- try/catch equiv.
         -- The REST string req.service is in form "obj/subobj/func"
         -- Iterate object hierarchy until we find the function 
         local x=rpc -- root
         for n in req.service:gmatch"(%w+)/?" do x = x[n] end
         if type(x) == "function" then func=x end
      end)
      if func then -- We found the requested function
         -- Call requested (AJAX) function in protected mode.
         -- Unpack and pass in all arguments
         local ok,rsp,err=pcall(func,table.unpack(req.args))
         if not ok then err=rsp rsp=nil end -- if code crashed
         -- Send AJAX response
         sock:write(ba.json.encode{rpcID=req.rpcID,rsp=rsp,err=err},true)
      elseif req and req.rpcID then
         -- Service not found, send 404
         sock:write(ba.json.encode{rpcID=req.rpcID,err=404}, true)
      else
         break -- Invalid data. Close socket.
      end
   end
end


-- Convert WebSocket HTTP request to WebSocket (WS) and
-- activate the AJAX service function as a cosocket.
if request:header"Sec-WebSocket-Key" then
   local s = ba.socket.req2sock(request)
   if s then
      s:event(service,"s")
      return
   end
end
response:senderror(404, "Not a WebSocket request")
?>
