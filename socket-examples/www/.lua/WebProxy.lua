
local webServerName="simplemq.com"
local fmt=string.format

local clientcnt,servercnt=0,0

local function webProxy(source,sink,isclient)
   trace(fmt("Starting %s proxy function:",
             isclient and "client" or "server"))
   local data,err
   while true do
      data,err = source:read()
      if not data then break end
      if isclient then
         clientcnt = clientcnt + #data
         trace(fmt("%s\t%d\t%d", "<", #data, clientcnt))
      else
         servercnt = servercnt + #data
         trace(fmt("%s\t%d\t%d", ">", #data, servercnt))
      end
      data,err=sink:write(data)
      if not data then break end
   end
   trace(fmt("End %s proxy function: %s.",
             isclient and "client" or "server", err))
   sink:close()
end

-- Proxy client for the WEB server
local function webProxyClient(client, server)
   local s,err = ba.socket.connect(webServerName,80);
   if s then
      assert(s == client) -- Just to show that this is always true
      server:enable(client) -- (Ref-p)
      webProxy(client, server, true)
   else
      trace(fmt("Cannot connect to %s: %s",webServerName,err))
      server:enable() -- (Ref-p)
   end
end


-- Proxy server for the WEB client
local function webProxyServer(server)
   trace"Creating WEB proxy connection"
   ba.socket.event(webProxyClient,server)
   local client=server:disable() -- pause (Ref-p)
   if client then
      webProxy(server, client, false)
   end
end


-- A standard socket accept coroutine, accept new web clients.
local function accept(s)
   while true do
      local s = s:accept(s)
      if not s then break end -- If server listen socket was closed.
      s:event(webProxyServer,"s") -- Activate the cosocket.
   end
end


-- Open listen port in range 8080 to 8090
local sock
local tp=8080
while tp < 8090 do
   sock=ba.socket.bind(tp)
   if sock then break end
   tp=tp+1
end
proxyPort=tp -- Global in app table

if sock then
   sock:event(accept,"r")
   trace(fmt("Web Proxy Server listening on port %d.", tp))
else
   trace"Web Proxy Server: Cannot open listen port!"
end
