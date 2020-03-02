--Create alias
local fmt=string.format

-- Web server function running in the context of the Lua thread pool.
-- s is the blocking socket.
local function webServer(s)
    -- Read request
   local data,err = s:read(2000)
   -- Ignore request -- i.e. discard data.

   -- Send the same response for any URL requested
   local msg = "Hello World!"
   s:write(fmt("%s\r\n%s\r\n%s%d\r\n\r\n%s", 
               "HTTP/1.0 200 OK",
               "Content-Type: text/plain",
               "Content-Length: ",
               #msg, msg))
   s:close()
end


local thread=ba.thread.create() -- One worker thread

-- Accept thread waiting asynchronously for client connections
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

-- Create a secure (SSL) server listen object.
local s=ba.socket.bind(9443, {shark=sharkobj})
-- Run the socket "accept" function.
if s then
   s:event(acceptCoroutine,"r")
   trace"Secure Lua Web Server listening on port 9443: Navigate to https://name:9443"
else
   trace"Cannot start Secure Lua Web Server, port 9443 is in use!"
end

