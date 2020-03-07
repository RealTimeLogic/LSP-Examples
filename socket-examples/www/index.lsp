<?lsp

local host = request:header"host"
if host then
   host = string.gsub(host,":%d+","")
else
   host = request:sockname()
   if host == "::1" then host = "127.0.0.1" end
end

local webServerAddr = string.format("https://%s:9443",host)
local proxyAddr = app.proxyPort and string.format("http://%s:%d",host,app.proxyPort) or "ERROR!"

?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<title>Lua Socket Examples</title>
<style>
body {
    max-width: 45em;
    margin: 0 auto;
    font-family: Tahoma, Verdana, Arial, sans-serif;
}

table{border-collapse:collapse;width:100%;}
table,th,td{border:1px solid black}
th{background: #969696}
th,td{
padding-left:5px;padding-right:5px;padding-top:0;padding-bottom:0;
margin-top:0;
margin-bottom:0;
}

</style>
</head>
<body>
<h1>Lua Socket Examples</h1>

<h2>Blocking Web Socket Server</h2>

<p>The Blocking Web Socket Server example is similar to the example included in the Lua Tutorials. You may try the online copy of the <a href="https://embedded-app-server.info/WebSockets.lsp">Lua Tutorials : Web Socket Server</a> prior to running this example.</p>

<p><b>Blocking Web Socket Server Example: <a href="Blocking-WS-Server/">Blocking-WS-Server/</a></b>

<p>The above example (link) runs in the context of an LSP page, which in turn uses one of the threads from the Barracuda Server Pool, as illustrated in the following diagram:</p>
<img src="https://realtimelogic.com/ba/doc/en/img/BaEventContainer.png" alt=""/>

<p>When you run the above example, pay attention to the text "New WebSocket connection" and the text "End of Request/Response" being printed in the console. The server side WebSocket example runs until the browser closes the connection. Click the above link and let it run for a while, then click the back button in the browser.</p>

<p>We do not recommend running a socket thread using the Barracuda Server Pool. You may modify the example ws.lsp and instead run the WebSocket server in the context of the Lua Thread Library. See the comments in Blocking-WS-Server/ws.lsp and modify the code as instructed.  When running the modified example, make sure to pay attention to the two messages "New WebSocket connection" and "End of Request/Response" being printed in the console.</p>

<h2>Cosocket Web Socket Server</h2>

<p>Cosockets are recommended for any implementation using several sockets simultaneously. A cosocket appears to be blocking, but is under the hood using non blocking sockets. The following example is a modified version of the above Blocking Web Socket Server. </p>

<p><b>Cosocket Web Socket Server Example: <a href="Blocking-WS-Server/">Cosockets-WS-Server/</a></b>

<p>Compare the two files Blocking-WS-Server/ws.lsp and Cosocket-WS-Server/ws.lsp</p>

<h2>Designing Socket Protocols in Lua: Companion Examples</h2>
<p>The following examples are the companion examples for the <a href="https://realtimelogic.com/ba/doc/?url=SockLib.html">Socket API Design Document</a>. Clicking the first column below takes you to the online example documentation and clicking column two runs the example.</p>

<table>
<tr><th>Documentation</th><th>Execute</th><th>Information</th></tr>
<tr>
<td><a href="https://realtimelogic.com/ba/doc/en/lua/SockLib.html#example1">Example 1</a></td>
<td><a href="ntp.lsp">ntp.lsp</a></td>
<td>Blocking socket example. NTP (Network Time Protocol) client</td>
</tr>
<tr>
<td><a href="https://realtimelogic.com/ba/doc/en/lua/SockLib.html#example2">Example 2</a></td>
<td><a href="wsecho.lsp">wsecho.lsp</a></td>
<td>Blocking WebSocket client example</td>
</tr>
<tr>
<td><a href="https://realtimelogic.com/ba/doc/en/lua/SockLib.html#example3">Example 3</a></td>
<td><a href="<?lsp=webServerAddr?>"><?lsp=webServerAddr?></a></td>
<td>A basic HTTP 1.0 web server, running in the context of a native thread</td>
</tr>
<tr>
<td><a href="https://realtimelogic.com/ba/doc/en/lua/SockLib.html#example6">Example 6</a></td>
<td><a href="asyncntp.lsp">asyncntp.lsp</a></td>
<td>A modified version of example 1, where the socket is asynchronous</td>
</tr>
<tr>
<td><a href="https://realtimelogic.com/ba/doc/en/lua/SockLib.html#example13">Example 13</a></td>
<td><a href="<?lsp=proxyAddr?>/fs/tmp/"><?lsp=proxyAddr?>/fs/tmp/</a></td>
<td>A non blocking proxy implemented in Lua</td>
</tr>
<tr>
<td></td>
<td><a href="/eliza/">/eliza/</a></td>
<td>ELIZA the psychotherapist, a WebSocket server example</td>
</tr>
</table>


<p>Example 13 (non blocking proxy) shows how flow control is managed when using cosockets. In order to test this, we need a service that enables us to send and receive large files. The destination server for the proxy is set to the online Barracuda App Server's Web File Manager (<a href="https://embedded-app-server.info/fs/tmp/">http://embedded-app-server.info/fs/tmp/</a>). When you click the proxy address <a href="<?lsp=proxyAddr?>/fs/tmp/"><?lsp=proxyAddr?>/fs/tmp/</a>, the proxy tunnels your request to the online server's <a href="https://realtimelogic.com/ba/doc/?url=lua.html#ba_create_wfs">Web File Manager</a>. Note that the proxy fails if you attempt to use or switch to a secure connection. Use a browser that supports drag and drop, such as Chrome, and drop a file into the Web File Manager's web interface. The file dropped into your browser window uploads via your local proxy. The proxy prints out the data usage to the console window when actively working.</p>

</body>
</html>
