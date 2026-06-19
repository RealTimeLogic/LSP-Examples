<?lsp
if request:header"Sec-WebSocket-Key" then
   local s = ba.socket.req2sock(request)
   if s then
      s:event(app.newClient,"s")
      request:abort() -- We are done
   end
end
response:sendredirect"minnow/"
?>
