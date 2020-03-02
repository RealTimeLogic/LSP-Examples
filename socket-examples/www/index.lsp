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

<table>
<tr><th>Documentation</th><th>Execute</th><th>Information</th></tr>
<tr>
<td><a href="https://realtimelogic.com/ba/doc/en/lua/SockLib.html#example1">Example 1</a></td>
<td><a href="ntp.lsp">ntp.lsp</a></td>
<td>Blocking socket example. NTP (Network Time Protocol Client)</td>
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


<p>Example 13 (non blocking proxy) shows how flow control is managed when using cosockets. In order to test this, we need a service that enables us to send and receive large files. The destination server for the proxy is set to the online Barracuda App Server's Web File Manager (<a href="http://lua-tutorial.tk/fs/tmp/">http://lua-tutorial.tk/fs/tmp/</a>). When you click the proxy address <a href="<?lsp=proxyAddr?>/fs/tmp/"><?lsp=proxyAddr?>/fs/tmp/</a>, the proxy tunnels your request to the online server's <a href="https://realtimelogic.com/ba/doc/?url=lua.html#ba_create_wfs">Web File Manager</a>. Note that the proxy fails if you attempt to use or switch to a secure connection. Use a browser that supports drag and drop, such as Chrome, and drop a file into the Web File Manager's web interface. The file dropped into your browser window uploads via your local proxy. The proxy prints out the data usage to the console window when actively working.</p>

</body>
</html>
