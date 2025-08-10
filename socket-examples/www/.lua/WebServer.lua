--[[        Basic Web Server

1. Opening a listening socket: The code creates a secure server socket
that listens on port 9443 using ba.socket.bind.

2. Listening socket waiting for connections: The function
acceptCoroutine is registered as an event handler with
s:event(acceptCoroutine, "r").

The accept method waits for clients to connect.

3. Running the basic server for each connection: When a connection is
accepted, the code runs webServer(s) in a separate worker thread
(thread:run(...)).

Function webServer reads and parses the client's request.
It sends back a simple page with data received from the client.

Finally, it closes the socket.

Details: https://realtimelogic.com/ba/doc/en/lua/SockLib.html#BlockingSockets
--]]


--Create alias
local fmt=string.format

-- 3: Web server function running in the context of the Lua thread pool.
-- s is the blocking socket.
local function webServer(s)
    -- Read request
   local data,err = s:read(2000)
   if not data then return end
   -------- Split head/body --------
   local head, body = data:match("^(.-)\r?\n\r?\n(.*)$")
   head = head or data
   body = body or ""
   -------- Request line --------
   local requestLine = head:match("^[^\r\n]+") or ""
   local method, target = requestLine:match("^(%u+)%s+([^%s]+)")
   method = method or "GET"
   target = target or "/"

   -- Path + query
   local path, query = target:match("^([^%?]+)%??(.*)$")
   path = path or "/"
   -------- Headers --------
   local headers = {}
   for name, value in head:gmatch("\r?\n([%w%-%_%.]+):%s*([^\r\n]+)") do
      local key = name:lower()
      headers[key] = value
   end
   -- Assemble response
   local rsp = {"<h1>Hello</h1><p>You sent:</p><pre>",method.." "..path}
   for k,v in pairs(headers) do table.insert(rsp,k.." : "..v) end
   table.insert(rsp,"</pre>")
   rsp=table.concat(rsp,"\n")
   s:write(fmt("%s\r\n%s\r\n%s%d\r\n\r\n%s", 
               "HTTP/1.0 200 OK",
               "Content-Type: text/html",
               "Content-Length: ",
               #rsp, rsp))
   s:close()
end


local thread=ba.thread.create() -- One worker thread

-- 2: Accept thread waiting asynchronously for client connections
local function acceptCoroutine(s)
   while true do
      -- Method accept yields and resumes when a client connects.
      local s = s:accept(s)
      if not s then break end -- Server terminating
      -- Delegate execution of the new blocking socket to the thread pool.
      -- Notice how we create an anonymous function that keeps the socket as
      -- a closure. When the anonymous function starts, it calls function
      -- webServer() passing in the socket.
      thread:run(function() webServer(s) end)
   end
end

-- Create a SharkSSL certificate by using the certificate stored in
-- the internal ZIP file.
local iovm = ba.openio("vm")

local certf=".certificate/MakoServer.%s"
local cert,err=ba.create.sharkcert(
        iovm, fmt(certf,"pem"), fmt(certf,"key"), "sharkssl")
if not cert then error"Certificate not found in mako.zip" end

-- Create a SharkSSL server object by using the above certificate
local sharkobj=ba.create.sharkssl(nil,{server=true})
sharkobj:addcert(cert)

-- 1: Create a secure (SSL) server listen object.
local s=ba.socket.bind(9443, {shark=sharkobj})
-- Run the socket "accept" function.
if s then
   s:event(acceptCoroutine,"r")
   trace"Secure Lua Web Server listening on port 9443: Navigate to https://localhost:9443"
else
   trace"Cannot start Secure Lua Web Server, port 9443 is in use!"
end

