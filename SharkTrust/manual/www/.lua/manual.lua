local M,service={}

function M.init(acme) service=acme end

local function authorized(request)
   if request:user() then return true,"authenticated" end
   local peer=request:peername()
   if peer == "127.0.0.1" or peer == "::1" or peer == "::ffff:127.0.0.1" then
      return true,"local"
   end
   return false
end

local function token(request)
   local session=request:session(true)
   if not session.manualDnsCsrf then
      session.manualDnsCsrf=ba.b64urlencode(ba.rndbs(24))
   end
   return session.manualDnsCsrf
end

local function problem(code,message)
   return {ok=false,error={code=code,message=message}}
end

local function snapshot(acme)
   if not acme or type(acme.status) ~= "function" then
      return {configured=false,manual=false,phase="unavailable",
         message="Manual DNS-01 is not configured."}
   end

   local status=acme:status()
   local challenge=status.registration
   local manual=type(challenge) == "table" and challenge.type == "manual"
   local domains={}
   for name,record in pairs(status.domains or {}) do
      domains[#domains+1]={name=name,expiresAt=record.expiresAt,renewAt=record.renewAt}
   end
   table.sort(domains,function(a,b) return a.name < b.name end)

   local lastError=status.lastError
   if type(lastError) == "table" then lastError=lastError.message or lastError.code end
   return {
      configured=true,
      manual=manual,
      phase=manual and challenge.phase or "unavailable",
      recordName=manual and challenge.recordName or nil,
      recordData=manual and challenge.recordData or nil,
      operation=status.operation,
      starting=status.starting == true,
      retryPending=status.retryPending == true,
      directoryUrl=status.directoryUrl,
      domains=domains,
      ready=status.started == true and #domains > 0 and not status.operation,
      error=lastError
   }
end

local function send(response,status,value)
   response:setstatus(status)
   response:setheader("Cache-Control","no-store")
   return response:json(value,false,true)
end

local function sendDeferred(defresp,status,value)
   if not defresp:valid() then return end
   local body=ba.json.encode(value)
   defresp:setstatus(status)
   defresp:setheader("Cache-Control","no-store")
   defresp:setheader("Content-Type","application/json; charset=utf-8")
   defresp:setcontentlength(#body)
   defresp:send(body)
   defresp:close()
end

function M.status(request,response)
   if request:method() ~= "GET" then
      response:setheader("Allow","GET")
      return send(response,405,problem("method_not_allowed","Use GET for status requests."))
   end
   local canManage,access=authorized(request)
   local value=snapshot(service)
   value.ok,value.canManage,value.access=true,canManage,access or "read-only"
   if canManage then value.csrf=token(request) end
   return send(response,200,value)
end

function M.action(request,response)
   if request:method() ~= "POST" then
      response:setheader("Allow","POST")
      return send(response,405,problem("method_not_allowed","Use POST for manual DNS actions."))
   end
   local ok=authorized(request)
   if not ok then
      return send(response,401,problem("authentication_required",
         "Sign in or open the test from the local server."))
   end
   local length=tonumber(request:header"Content-Length")
   if length and length > 1024 then
      return send(response,413,problem("request_too_large","The action request is too large."))
   end
   local contentType=(request:header"Content-Type" or ""):lower()
   if not contentType:match"^application/x%-www%-form%-urlencoded" then
      return send(response,415,problem("unsupported_media_type","Use a URL-encoded form request."))
   end

   local action,csrf=request:data("action","csrf")
   if action ~= "continue" and action ~= "cancel" and action ~= "renew" then
      return send(response,400,problem("invalid_action","The requested action is not supported."))
   end
   local session=request:session(false)
   if not session or type(csrf) ~= "string" or csrf ~= session.manualDnsCsrf then
      return send(response,403,problem("invalid_request_token","Refresh the page and try again."))
   end

   local acme=service
   local challenge=acme and acme.challenge
   local state=snapshot(acme)
   if not state.manual or not challenge then
      return send(response,409,problem("manual_dns_not_configured",
         "Manual DNS-01 is not configured."))
   end
   if action == "renew" then
      local domain=state.ready and state.domains[1]
      if not domain or type(acme.renew) ~= "function" then
         return send(response,409,problem("renewal_unavailable","A new certificate cannot be requested now."))
      end
      local callbackError
      local started,err=acme:renew(domain.name,function(_,renewErr) callbackError=renewErr end)
      if not started then
         err=err or callbackError
         return send(response,409,problem(type(err) == "table" and err.code or "renewal_failed",
            type(err) == "table" and err.message or tostring(err or "Renewal failed.")))
      end
      local result=snapshot(acme)
      result.ok,result.csrf=true,csrf
      return send(response,202,result)
   end
   if state.phase ~= "publish" then
      return send(response,409,problem("no_pending_action","No operator action is pending."))
   end

   local defresp=response:deferred()
   local finished=false
   local function complete(value,err)
      if finished then return end
      finished=true
      if not value then
         local code=type(err) == "table" and err.code or "action_failed"
         local message=type(err) == "table" and (err.message or code) or tostring(err or code)
         return sendDeferred(defresp,409,problem(code,message))
      end
      local result=snapshot(acme)
      result.ok,result.csrf=true,csrf
      sendDeferred(defresp,200,result)
   end
   local started,err=challenge[action](challenge,complete)
   if not started and not finished then complete(nil,err) end
end

return M
