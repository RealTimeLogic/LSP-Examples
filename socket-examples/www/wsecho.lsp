<form>
  <p>Echo message:
     <input type="text" name="msg">
     <input type="submit" value="Submit">
  </p>
</form>
<?lsp
local msg=request:data"msg"
if msg then
   local h = require"httpc".create()
   h:request{url="ws://echo.websocket.org"}
   if h:status() == 101 then -- 101 switching protocol
      local s = ba.socket.http2sock(h)
      if s then
         s:write(msg)
         print'<h3>'
         print('Echo response:',s:read(5000))
         print'</h3>'
         s:close()
      end
   end
end
?>


