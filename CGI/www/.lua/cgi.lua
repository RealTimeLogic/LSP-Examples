
-- CGI emulator based on the forkpty plugin
-- https://realtimelogic.com/ba/doc/?url=auxlua.html#forkptylib

local fmt=string.format
local urlencode=ba.urlencode
local tinsert=table.insert
local tconcat=table.concat

local function flushresp(_ENV,respT)
   local headers,body=tconcat(respT):match"(.-\n)\n(.*)"
   if headers then
      local hcnt=0
      for k,v in headers:gmatch"(.-)%s*:%s*(.-)\n" do
         hcnt=hcnt+1
         if k == "Status" then
            v=v:match"%d+"
            if not v then
               response:senderror(503, "Invalid CGI 'Status'")
               return false
            end
            response:setstatus(tonumber(v))
         else
            response:setheader(k,v)
         end
      end
      if hcnt == 0 then
         response:senderror(503, "No CGI headers")
         return false
      end
      if body then
         response:write(body)
      end
   else
      response:senderror(503, "Invalid CGI header response")
      return false
   end
   return true
end

local function cgiservice(cgipath,_ENV,relpath)
   request:allow{"GET", "POST"}
   local headers=request:header()
   local queryL={}
   for k,v in request:datapairs() do
      tinsert(queryL,fmt('%s=%s',k,urlencode(v)))
   end
   local host,port=request:sockname()
   local domain=request:domain()
   local op={
      env={
         AUTH_TYPE=headers.Authorization and headers.Authorization:match"%a+",
         CONTENT_LENGTH=headers["Content-Length"],
         CONTENT_TYPE=headers["Content-Type"],
         GATEWAY_INTERFACE="CGI/1.1",
         PATH_INFO=relpath,
         QUERY_STRING=tconcat(queryL,'&'),
         REMOTE_ADDR=request:peername(),
         REMOTE_HOST=domain,
         REMOTE_USER=request:user(),
         REQUEST_METHOD=request:method(),
         SCRIPT_NAME=relpath,
         SERVER_NAME=fmt("%s %s",domain,host),
         SERVER_PORT=tostring(port),
         SERVER_PROTOCOL="HTTP/1.0",
         SERVER_SOFTWARE="BAS-CGI 1.0",
      }
   }
   response:reset()
   response:setdefaultheaders()
   local respT={}
   local respsize=0
   local pty,err=ba.forkpty(op, cgipath..relpath)
   if pty then
      local resp
      while true do
         resp,err = pty:read(3000)
         if not resp then break end
         if respT then
            tinsert(respT, resp)
            respsize = respsize + #resp
            if respsize > 1024 then
               if not flushresp(_ENV, respT) then return end
               respT=nil
            end
         else
            response:write(resp)
         end
      end
      if 0 == pty:close(true) then
         err=nil
      elseif "terminated" == err and #respT > 0 then
         tinsert(respT, '</pre>')
         err='<pre>'..tconcat(respT)
      end
   end
   if err then
      response:senderror(503, err)
   elseif respT then
      flushresp(_ENV, respT)
   end
   return true
end


local function create(cgipath,dirname,priority)
   local function service(_ENV,relpath)
      return cgiservice(cgipath,_ENV,relpath)
   end
   local dir = ba.create.dir(dirname ,priority)
   dir:setfunc(service)
   return dir
end

return {
   create=create
}

