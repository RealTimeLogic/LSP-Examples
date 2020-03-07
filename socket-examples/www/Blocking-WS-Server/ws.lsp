<?lsp

local function webSockFunc(s)
   local count = 1
   while true do
      local msg= string.format("hello %d",count)
      trace('',msg)
      if not s:write(msg, true) then -- Send message to client
         break -- Socket closed
      end
      ba.sleep(1000)
      count = count + 1
      if (ba == nil) then break end
   end
   trace"Closing WebSocket connection"
   s:close()
end


if request:header"Sec-WebSocket-Key" then
   trace"New WebSocket connection"
   local s = ba.socket.req2sock(request)
   if s then
      webSockFunc(s) --Use LSP thread
      -- Alternatively, use thread library
      --ba.thread.run(function() webSockFunc(s) end)
   end
   trace"End of Request/Response"
   return -- We are done
end
?>
WebSockets only!!!

