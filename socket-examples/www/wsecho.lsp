<html>
<head>
<title>WebSocket Echo Client</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<main>
<h1>WebSocket Echo Client</h1>
<p>This page sends one message to <code>wss://ws.postman-echo.com/raw</code> and prints the echoed response.</p>
<form>
  <p>Echo message:</p>
  <input type="text" name="msg">
  <input type="submit" value="Submit">
</form>
<?lsp
local msg=request:data"msg"
if msg then
   local h = require"httpc".create()
   h:request{url="wss://ws.postman-echo.com/raw"}
   trace"HTTP header response from: wss://ws.postman-echo.com/raw"
   for k,v in h:headerpairs() do trace(k,v) end
   if h:status() == 101 then -- 101 switching protocol
      local s = ba.socket.http2sock(h)
      if s then
         s:write(msg,true)
         print'<h3>'
         print('Echo response:',s:read(5000))
         print'</h3>'
         s:close()
      end
   else
      print("HTTP Resp err",h:status())
   end
end
?>
</main>
</body>
</html>

