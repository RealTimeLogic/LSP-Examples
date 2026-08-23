local fmt,jdecode=string.format,ba.json.decode
local jwt=require"jwt"

local DAY=24*60*60*1000
local TX_LIFETIME={mins=10}
local CLOCK_SKEW={mins=2}
local secretCodes={ [7000215]="credential-invalid", [7000222]="credential-expired" }

local function defaultLog(...) trace("SSO:",fmt(...)) end
local function newHttp() return require"httpm".create{trusted=true} end
local function random() return ba.b64urlencode(ba.rndbs(32)) end

local function parseDate(value)
   if type(value) ~= "string" or value == "" then return nil end
   local year,month,day=value:match"^(%d%d%d%d)%-(%d%d?)%-(%d%d?)$"
   if year then value=fmt("%04d-%02d-%02dT23:59:59Z",year,month,day) end
   return ba.datetime(value)
end

local function hasCode(codes,code)
   for _,v in ipairs(type(codes) == "table" and codes or {}) do
      if tonumber(v) == code then return true end
   end
end

local function notify(self,event)
   if not self.notify then return end
   local ok,err=pcall(self.notify,event)
   if not ok then self.log("Notification callback failed: %s",tostring(err)) end
end

local function notifyCredentialError(self,codes)
   for code,kind in pairs(secretCodes) do
      if hasCode(codes,code) and not self.notified[kind] then
         self.notified[kind]=true
         notify(self,{kind=kind,expires=self.openidT.client_secret_expires,
                      message=kind == "credential-expired" and
                         "The Microsoft Entra client secret has expired." or
                         "Microsoft Entra rejected the configured client secret."})
      end
   end
end

local function checkExpiry(self)
   local value=self.openidT.client_secret_expires
   local expires=parseDate(value)
   if not expires then return end
   local now=ba.datetime"NOW"
   if expires <= now then
      if not self.alerted.expired then
         self.alerted.expired=true
         self.notified["credential-expired"]=true
         notify(self,{kind="credential-expired",expires=value,
                      message="The Microsoft Entra client secret has expired."})
      end
      return
   end
   for _,days in ipairs(self.alertDays) do
      if now >= expires + {days=-days} then
         if not self.alerted[days] then
            self.alerted[days]=true
            notify(self,{kind="credential-expiring",expires=value,days=days,
                         message=fmt("The Microsoft Entra client secret expires within %d day%s.",
                                     days,days == 1 and "" or "s")})
         end
         return
      end
   end
end

local function loadKeys(self)
   if not self.provider then return nil,"OpenID provider metadata is unavailable" end
   local data,err=newHttp():json(self.provider.jwks_uri,{})
   if not data then return nil,err end
   local keys={}
   for _,key in ipairs(data.keys or {}) do
      if key.kid and key.kty == "RSA" and key.n and key.e then
         keys[key.kid]={n=ba.b64decode(key.n),e=ba.b64decode(key.e)}
      end
   end
   if not next(keys) then return nil,"No supported signing keys in JWKS" end
   self.keys=keys
   return true
end

local function loadProvider(self)
   local url=fmt("https://login.microsoftonline.com/%s/v2.0/.well-known/openid-configuration",
                 self.openidT.tenant)
   local data,err=newHttp():json(url,{})
   if not data then return nil,err end
   for _,name in ipairs{"authorization_endpoint","token_endpoint","jwks_uri","issuer"} do
      if type(data[name]) ~= "string" then return nil,"Incomplete OpenID provider metadata" end
   end
   self.provider=data
   return loadKeys(self)
end

local function refresh(self)
   local ok,err=loadProvider(self)
   if not ok then self.log("Cannot refresh OpenID provider data: %s",tostring(err)) end
   checkExpiry(self)
   return ok
end

local function startTimer(self)
   local timer
   timer=ba.timer(function()
      ba.thread.run(function()
         if self.closed then return end
         timer:reset(refresh(self) and DAY or 60000)
      end)
      return true
   end)
   self.timer=timer
   timer:set(DAY,false,true)
end

local function decodeToken(self,token)
   local encoded=type(token) == "string" and token:match"^([^.]+)%." or nil
   local decoded=encoded and ba.b64decode(encoded)
   local parsed,header=pcall(jdecode,decoded)
   header=parsed and header or nil
   if not header or header.alg ~= "RS256" or type(header.kid) ~= "string" then
      return nil,"Unsupported ID token header"
   end
   if not self.keys[header.kid] then
      local ok,err=loadKeys(self)
      if not ok then return nil,"Cannot refresh Microsoft signing keys: "..tostring(err) end
   end
   local called,ok,verified,payload=pcall(jwt.verify,token,self.keys,true)
   if not called or ok ~= true then
      return nil,type(verified) == "string" and verified or "Invalid ID token signature"
   end
   return verified,payload
end

local function validAudience(payload,clientId)
   if payload.aud == clientId then return not payload.azp or payload.azp == clientId end
   if type(payload.aud) ~= "table" then return false end
   for _,aud in ipairs(payload.aud) do
      if aud == clientId then return payload.azp == clientId end
   end
   return false
end

local function validateToken(self,token,nonce)
   local header,payload=decodeToken(self,token)
   if not header then return nil,payload end
   local nbf,exp=tonumber(payload.nbf),tonumber(payload.exp)
   local now=ba.datetime"NOW"
   local tenant=self.provider.issuer:match"^https://login%.microsoftonline%.com/([^/]+)/v2%.0$"
   if payload.ver ~= "2.0" or payload.iss ~= self.provider.issuer then return nil,"Invalid ID token issuer" end
   if not tenant or tostring(payload.tid):lower() ~= tenant:lower() then return nil,"Invalid ID token tenant" end
   if not validAudience(payload,self.openidT.client_id) then return nil,"Invalid ID token audience" end
   if payload.nonce ~= nonce then return nil,"Invalid ID token nonce" end
   if not nbf or not exp or ba.datetime(nbf) > now + CLOCK_SKEW or ba.datetime(exp) < now - CLOCK_SKEW then
      return nil,"ID token is outside its valid time range"
   end
   if type(payload.oid) ~= "string" or payload.oid == "" then return nil,"ID token has no object ID" end
   return header,payload
end

local function query(values)
   local out={}
   for _,item in ipairs(values) do out[#out+1]=item[1].."="..ba.urlencode(item[2]) end
   return table.concat(out,"&")
end

local function beginLogin(self,cmd,candidate)
   if not self.provider then return nil,"The Microsoft sign-in service is still starting. Please try again." end
   local session=cmd:session(true)
   if not session then return nil,"Cannot create a login session" end
   local verifier=random()
   local tx={state=random(),nonce=random(),verifier=verifier,
            expires=ba.datetime"NOW" + TX_LIFETIME,candidate=candidate}
   session.msSsoTransaction=tx
   local challenge=ba.b64urlencode(ba.crypto.hash"sha256"(verifier)(true))
   if candidate then session.msSsoRecovery=nil end
   cmd:sendredirect(self.provider.authorization_endpoint.."?"..query{
      {"client_id",self.openidT.client_id}, {"response_type","code"},
      {"redirect_uri",self.openidT.redirect_uri}, {"response_mode","query"},
      {"scope","openid profile"}, {"state",tx.state}, {"nonce",tx.nonce},
      {"code_challenge",challenge}, {"code_challenge_method","S256"}
   })
   return true
end

local function setRecovery(session)
   local recovery={token=random(),expires=ba.datetime"NOW" + TX_LIFETIME}
   session.msSsoRecovery=recovery
   return recovery.token
end

local function takeTransaction(cmd)
   local session=cmd:session()
   local tx=session and session.msSsoTransaction
   if not tx then return nil,"No login transaction was started" end
   if tx.expires < ba.datetime"NOW" then
      session.msSsoTransaction=nil
      return nil,"The login transaction expired"
   end
   if cmd:data"state" ~= tx.state then return nil,"Invalid login state" end
   session.msSsoTransaction=nil
   return tx,session
end

local function completeLogin(self,cmd)
   local tx,session=takeTransaction(cmd)
   if not tx then return nil,session end
   local providerError=cmd:data"error"
   if providerError then
      self.log("Microsoft sign-in returned: %s",tostring(providerError))
      return nil,"Microsoft sign-in was not completed"
   end
   local code=cmd:data"code"
   if type(code) ~= "string" or code == "" then return nil,"No authorization code was returned" end
   local secret=tx.candidate and tx.candidate.secret or self.openidT.client_secret
   local status,data=newHttp():post(self.provider.token_endpoint,{
      client_id=self.openidT.client_id,client_secret=secret,code=code,
      redirect_uri=self.openidT.redirect_uri,grant_type="authorization_code",
      code_verifier=tx.verifier
   })
   local parsed,rsp
   if type(data) == "string" then parsed,rsp=pcall(jdecode,data) end
   rsp=parsed and rsp or nil
   if status ~= 200 or not rsp or type(rsp.id_token) ~= "string" then
      local codes=rsp and rsp.error_codes
      notifyCredentialError(self,codes)
      self.log("Token exchange failed: status=%s error=%s code=%s",tostring(status),
               tostring(rsp and rsp.error or "invalid_response"),
               tostring(codes and codes[1] or "none"))
      local recovery
      if hasCode(codes,7000215) or hasCode(codes,7000222) then recovery=setRecovery(session) end
      return nil,"Microsoft Entra could not complete sign-in",codes,recovery
   end
   local header,payload=validateToken(self,rsp.id_token,tx.nonce)
   if not header then
      self.log("ID token validation failed: %s",tostring(payload))
      return nil,"The Microsoft identity response could not be validated"
   end
   if tx.candidate then
      self.openidT.client_secret=tx.candidate.secret
      self.openidT.client_secret_expires=tx.candidate.expires
      self.alerted={}
      self.notified={}
      if self.savecredential then
         local ok,saved,err=pcall(self.savecredential,tx.candidate.secret,{expires=tx.candidate.expires})
         if not ok or saved == false or saved == nil then
            self.log("Credential persistence callback failed: %s",tostring(ok and err or saved))
            notify(self,{kind="credential-update-failed",expires=tx.candidate.expires,
                         message="The new client secret works, but the application could not persist it."})
         end
      end
      notify(self,{kind="credential-updated",expires=tx.candidate.expires,
                   message="The Microsoft Entra client secret was updated."})
   end
   session.msSsoRecovery=nil
   return header,payload
end

local function rotate(self,cmd,secret,expires,token)
   local session=cmd:session()
   local recovery=session and session.msSsoRecovery
   if not recovery or recovery.token ~= token or recovery.expires < ba.datetime"NOW" then
      return nil,"The replacement was not tested because this recovery form was already submitted or expired"
   end
   if type(secret) ~= "string" or #secret < 8 or #secret > 512 then
      return nil,"Enter the client secret Value",recovery.token
   end
   local date=parseDate(expires)
   if not date or date <= ba.datetime"NOW" then
      return nil,"Enter the future expiration date shown in Microsoft Entra",recovery.token
   end
   return beginLogin(self,cmd,{secret=secret,expires=expires})
end

local function init(openidT,loginOrOptions,options)
   assert(type(openidT) == "table","openid configuration table required")
   for _,name in ipairs{"tenant","client_id","client_secret","redirect_uri"} do
      assert(type(openidT[name]) == "string" and openidT[name] ~= "","openid."..name.." is required")
   end
   assert(openidT.redirect_uri:match"^https://" or openidT.redirect_uri:match"^http://localhost[:/]",
          "openid.redirect_uri must use HTTPS, except on localhost")
   if openidT.client_secret_expires == nil then
      local today=ba.datetime"NOW":date()
      openidT.client_secret_expires=fmt("%04d-%02d-%02d",today.year,today.month,today.day)
   end
   assert(parseDate(openidT.client_secret_expires),
          "openid.client_secret_expires must be a valid date")
   if type(loginOrOptions) == "table" and options == nil then options=loginOrOptions end
   options=type(options) == "function" and {log=options} or options or {}
   local alertDays={}
   for _,days in ipairs(options.alert_days or openidT.alert_days or {1,7,14,30,60}) do
      assert(type(days) == "number" and days > 0,"alert_days must contain positive numbers")
      alertDays[#alertDays+1]=days
   end
   local self={openidT=openidT,keys={},provider=nil,closed=false,
               notified={},alerted={},notify=options.notify,savecredential=options.savecredential,
               alertDays=alertDays}
   table.sort(self.alertDays)
   self.log=options.log and function(...) options.log(fmt(...)) end or defaultLog
   startTimer(self)
   return {
      sendredirect=function(cmd) return beginLogin(self,cmd) end,
      login=function(cmd) return completeLogin(self,cmd) end,
      rotate=function(cmd,secret,expires,token) return rotate(self,cmd,secret,expires,token) end,
      decode=function(token) return decodeToken(self,token) end,
      close=function() if not self.closed then self.closed=true self.timer:cancel() end end
   }
end

return {init=init}
