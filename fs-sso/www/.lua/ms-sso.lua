

local fmt=string.format
local jdecode=ba.json.decode

local aesencode,aesdecode=(function()
   local aeskey=ba.aeskey(32)
   return function(data) return ba.aesencode(aeskey,data) end,
   function(data) return ba.aesdecode(aeskey,data) end
end)()

local function downloadKeys(msKeysT,openidT,http)
   tracep(20,"Downloading MS openid keys")
   local run=true
   local function exit() http:close() run=false end
   if mako then mako.onexit(exit,true) end
   local url=fmt("%s%s%s","https://login.microsoftonline.com/",openidT.tenant,"/discovery/keys")
   local d=ba.b64decode
   while run do
      local t,err=http:json(url,{})
      if t then
         for _,t in ipairs(t and t.keys or {}) do
            msKeysT[t.kid] = {n=d(t.n),e=d(t.e)}
         end
         return true
      end
      trace("Cannot download",url,err)
   end
end

-- JWT: decode and verify compact format (header.payload.signature) with RSA signature
local function jwtDecode(token,msKeysT,verify)
   local err
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
               err=(fmt("Unknown JWT kid %s",header.kid))
            end
         else
            return header,payload
         end
      end
   end
   return nil, (err or "Invalid JWT")
end


local function init(openidT)
   assert(type(openidT.tenant) == "string","tenant")
   assert(type(openidT.client_id) == "string","client_id")
   assert(type(openidT.client_secret) == "string","client_secret")
   assert(type(openidT.redirect_uri) == "string","redirect_uri")

   local http = require"httpm".create{trusted=true}
   local msKeysT={}
   local oneHour=60*60*1000 -- in millisecs
   local oneDay=24*oneHour
   local downloadKeysTimer
   local function downloadKeysTimerFunc()
      ba.thread.run(function()
         local keysT={}
         if downloadKeys(keysT,openidT,http) then
            msKeysT=keysT
            downloadKeysTimer:reset(oneDay)
         else
            downloadKeysTimer:reset(oneHour)
         end
      end)
      return true
   end
   downloadKeysTimer=ba.timer(downloadKeysTimerFunc)
   downloadKeysTimer:set(oneDay, true, true)

   local function loginCallback(cmd)
      local err
      local data=cmd:data()
      local code,state=data.code,data.state
      if code then
         local status,data = http:post(fmt("%s%s%s",
           "https://login.microsoftonline.com/",openidT.tenant,"/oauth2/v2.0/token"),
           {
              client_id=openidT.client_id,
              client_secret=openidT.client_secret,
              code=code,
              redirect_uri=openidT.redirect_uri,
              grant_type="authorization_code"
           })
         -- RSP: https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow
         local rspT = jdecode(data)
         if status == 200 and rspT and rspT.id_token and rspT.access_token then
            -- id_token: https://docs.microsoft.com/en-us/azure/active-directory/develop/id-tokens
            local header,payload=jwtDecode(rspT.id_token,msKeysT,openidT.tenant ~= "common")
            if header then
               local now=ba.datetime"NOW"
               local dt = ba.datetime(aesdecode(payload.nonce or "") or "MIN")
               if (dt + {mins=10}) > now and ba.datetime(payload.nbf) <= now and ba.datetime(payload.exp) >= now then
                  if payload.aud == openidT.client_id then
                     return header,payload,rspT.access_token
                  end
                  err='Invalid "aud" (Application ID)'
               end
               err="Login session expired"
            else
               err=payload
            end
         elseif rspT and rspT.error_description then
            err=rspT.error_description
         else
            trace("Error response",status, data)
         end
      elseif data.error_description then
         err=data.error_description
      end
      err = err or "Not a JWT response"
      return nil,err
   end

   local function sendLoginRedirect(cmd)
      local state= openidT.state == "url" and ba.b64urlencode(cmd:url()) or "local"
      local nonce=aesencode(ba.datetime"NOW":tostring())
      cmd:sendredirect(fmt("%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
                           "https://login.microsoftonline.com/",openidT.tenant,"/oauth2/v2.0/authorize?",
                           "client_id=",openidT.client_id,
                           "&response_type=code",
                           "&redirect_uri=",ba.urlencode(openidT.redirect_uri),
                           "&response_mode=form_post",
                           "&scope=openid+profile",
                           "&state=",state,
                           "&nonce=",ba.urlencode(nonce)))
   end

   return {
      sendLoginRedirect=sendLoginRedirect,
      loginCallback=loginCallback,
      jwtDecode = function(token) return jwtDecode(token, msKeysT) end
   }

end -- init

return {init=init}
