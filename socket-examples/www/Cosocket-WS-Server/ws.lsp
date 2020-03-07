<?lsp

local function webSockFunc(s)
   local count = 1
   while true do
      local msg= string.format("hello %d",count)
      trace('',msg)
      if not s:write(msg, true) then -- Send message to client
         break -- Socket closed
      end
      -- We cannot use ba.sleep in a cosocket, but we can use a timer.
      -- We can also use 'read' with a timeout as a timer since we do
      -- not receive data.
      s:read(1000)
      count = count + 1
   end
   trace"Closing WebSocket connection"
   s:close()
end


if request:header"Sec-WebSocket-Key" then
   trace"New WebSocket connection"
   local s = ba.socket.req2sock(request)
   if s then
      -- Run 'webSockFunc' as a cosocket
      --See https://realtimelogic.com/ba/doc/?url=auxlua.html#socket_event
      s:event(webSockFunc,"s")
   end
   trace"End of Request/Response"
   return -- We are done
end
?>
WebSockets only!!!

