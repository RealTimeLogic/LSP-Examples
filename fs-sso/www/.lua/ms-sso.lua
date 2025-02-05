local fmt,jdecode=string.format,ba.json.decode
local msKeysT,http,openidT,downloadKeysTimer={},require"httpm".create{trusted=true}
local loginPage
local function log(...) trace("SSO:",fmt(...)) end

local aesencode,aesdecode=(function()
   local aeskey=ba.aeskey(32)
   return function(data) return ba.aesencode(aeskey,data) end,
   function(data) return ba.aesdecode(aeskey,data) end
end)()

local function getRedirUri(cmd)
   return cmd:url():match"^https?://[^/]+"..loginPage
end

local function validate(secret)
   local err,desc
   local secret=secret or openidT.client_secret
   local status,data = http:post(fmt("%s%s%s",
      "https://login.microsoftonline.com/",openidT.tenant,"/oauth2/v2.0/token"),
      {
	 client_id=openidT.client_id,
	 client_secret=secret,
	 grant_type="client_credentials",
	 scope="https://graph.microsoft.com/.default",
      })
   local rspT = jdecode(data)
   if rspT then
      if not rspT.token_type then
         err,desc=rspT.error,rspT.error_description
      end
   else
      err=fmt("Error response %s, %s",tostring(status), tostring(data))
   end
   if not err then
      openidT.client_secret=secret
      return true
   end
   return nil,err,desc
end


local function downloadKeys()
   local url=fmt("%s%s%s","https://login.microsoftonline.com/",openidT.tenant,"/discovery/keys")
   local d=ba.b64decode
   local t,err=http:json(url,{})
   if t then
      msKeysT={}
      for _,x in ipairs(t and t.keys or {}) do
	 msKeysT[x.kid] = {n=d(x.n),e=d(x.e)}
      end
      return true
   end
   log("Cannot download signing keys %s: %s",url,err)
end

local function startKeysDownload()
   if downloadKeysTimer then downloadKeysTimer:cancel() end
   local oneDay=24*60*60*1000
   local doValidate=true
   downloadKeysTimer=ba.timer(function()
      ba.thread.run(function()
         local ok=downloadKeys()
         if ok and doValidate then
            local ok,err,desc=validate()
            if not ok then
               log("Invalid settings: '%s' %s", err, desc or "")
            end
            doValidate=false
         end
         downloadKeysTimer:reset(ok and oneDay or 60000)
      end)
      return true
   end)
   downloadKeysTimer:set(oneDay,true,true)
   if mako then mako.onexit(function() downloadKeysTimer:cancel() end,true) end
end


-- JWT: decode and verify compact format (header.payload.signature) with RSA signature
local function jwtDecode(token,verify)
   local err
   if not next(msKeysT) then return nil, "Waiting for signing keys to be downloaded" end
   local signedData=token:match"([^%.]+%.[^%.]+)"
   local header,payload,signature=token:match"([^%.]+)%.([^%.]+)%.([^%.]+)"
   if signedData and header then
      local d=ba.b64decode
      header,payload,signature = jdecode(d(header) or ""),jdecode(d(payload) or""),d(signature)
      if header and payload and signature then
	 if verify then
	    local keyT = msKeysT[header.kid]
	    if keyT then
	       if ba.crypto.verify(signedData,signature,keyT) then
		  return header,payload
	       else
		  err="Invalid JWT signature"
	       end
	    else
	       err=(fmt("Unknown JWT kid %s, signing keys may have expired",header.kid))
	    end
	 else
	    return header,payload
	 end
      end
   end
   return nil, (err or "Invalid JWT")
end

local function init(idT,login,logFunc)
   openidT,loginPage=idT,login
   if logFunc then log=function(...) logFunc(fmt(...)) end end
   startKeysDownload()
   local function loginCallback(cmd)
      local err,ecodes,rspT -- string,array,table
      local data=cmd:data()
      local code=data.code
      if code then
	 local status,d = http:post(fmt("%s%s%s",
	   "https://login.microsoftonline.com/",openidT.tenant,"/oauth2/v2.0/token"),
	   {
	      client_id=openidT.client_id,
	      client_secret=openidT.client_secret,
	      code=code,
	      redirect_uri=getRedirUri(cmd),
	      grant_type="authorization_code"
	   })
	 rspT = jdecode(d)
	 if status == 200 and rspT and rspT.id_token and rspT.access_token then
	    local header,payload=jwtDecode(rspT.id_token,openidT.tenant ~= "common")
	    if header then
	       local now=ba.datetime"NOW"
	       local dt = ba.datetime(aesdecode(payload.nonce or "") or "MIN")
	       if (dt + {mins=10}) > now and ba.datetime(payload.nbf) <= now and ba.datetime(payload.exp) >= now then
		  if payload.aud == openidT.client_id then
		     return header,payload,rspT.access_token
		  end
		  err='Invalid "aud" (Application ID)'
	       else
		  err="Login session expired"
	       end
	    else
	       err=payload
	    end
	 elseif rspT and rspT.error_description then
	    err=rspT.error_description
	 else
	    log("Error response %d, %s",status, tostring(d))
	 end
      elseif data.error_description then
	 err=data.error_description
      end
      err = err or "Not a JWT response"
      ecodes=rspT and rspT.error_codes
      return nil,err,ecodes
   end --loginCallback

   local function sendLoginRedirect(cmd)
      local state= openidT.state == "url" and ba.b64urlencode(cmd:url()) or "local"
      local nonce=aesencode(ba.datetime"NOW":tostring())
      cmd:sendredirect(fmt("%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
			   "https://login.microsoftonline.com/",openidT.tenant,"/oauth2/v2.0/authorize?",
			   "client_id=",openidT.client_id,
			   "&response_type=code",
			   "&redirect_uri=",ba.urlencode(getRedirUri(cmd)),
			   "&response_mode=form_post",
			   "&scope=openid+profile",
			   "&state=",state,
			   "&nonce=",ba.urlencode(nonce)))
   end

   return {
      validate=validate,
      sendredirect=sendLoginRedirect,
      login=loginCallback,
      decode = function(token) return jwtDecode(token) end
   }
end -- init

return {init=init}
