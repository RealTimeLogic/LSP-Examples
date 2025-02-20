local fmt,sbyte=string.format,string.byte
local cbor=require"org.conman.cbor"
local json=ba.json
local b64enc,b64dec=ba.b64urlencode,ba.b64decode
local secretKey=ba.aeskey(32)

local function now()
   local secs=ba.datetime"NOW":ticks()
   return secs
end

local function bytesToHex(str)
    return str:gsub('.', function(byte) return fmt('%02X', sbyte(byte)) end)
end

-- WebAuth userId is locked to username in this implementation
local function user2id(user)
   return b64enc(ba.crypto.hash("hmac","sha256","u2IdKey")(user)(true))
end

local function origin(self,cmd)
   if self._origin then return self._origin end
   return (cmd:issecure() and "https://" or "http://")..cmd:domain()
end

local function rpId(self,cmd)
   return self._rp.id or cmd:domain()
end

local function createChallenge(cmd,user)
   return ba.aesencode(secretKey,json.encode{time=now(),ip=cmd:peername(),user=user})
end

local function validateChallenge(cmd,challenge)
   local t=json.decode(ba.aesdecode(secretKey,challenge))
   assert(t.time+61 > now(), "challenge expired")
   assert(t.ip == cmd:peername(), "IP address changed")
   return t.user
end

local function validateClientDataJSON(self,cmd,clientDataJSON,webauthType)
   clientDataJSON=b64dec(clientDataJSON or '')
   local clientData = json.decode(clientDataJSON or '')
   assert(clientData,"Invalid clientDataJSON")
   assert(clientData.type == "webauthn."..webauthType, "Invalid clientData type")
   local username=validateChallenge(cmd,clientData.challenge)
   assert(clientData.origin == origin(self,cmd),"Origin mismatch")
   assert(clientData.crossOrigin ~= true, "crossOrigin mismatch")
   return username,clientDataJSON
end

local function validateRegistration(self,cmd,data)
   local resp=data.response
   local user=validateClientDataJSON(self,cmd,resp.clientDataJSON,"create")
   -- Decode attestationObject
   local attestationData=cbor.decode(b64dec(resp.attestationObject))
   local authData=attestationData.authData
   assert(#authData > 37, "authData too short")
   -- Continue with `authData` validation
   local offset = 0
   -- RP ID Hash
   local rpIdHash = authData:sub(offset + 1, offset + 32)
   offset = offset + 32
   -- Validate RP ID Hash
   local expectedRpIdHash = ba.crypto.hash("sha256")(rpId(self,cmd))(true,"binary")
   assert(rpIdHash == expectedRpIdHash,"RP ID hash mismatch")
   -- Flags
   local flags = authData:byte(offset + 1)
   offset = offset + 1
   -- Signature Counter
   local signatureCounter = ba.socket.n2h(4, authData, offset + 1)
   offset = offset + 4
   -- Validate User Presence & Verification
   assert((flags & 0x01) ~= 0,"User was not physically present!")
   -- Attested Credential Data (if present)
   local attestationFlag = (flags & 0x40) ~= 0
   assert(0 ~= attestationFlag, "Missing Attested Credential")
   -- AAGUID (16 bytes)
   -- local aaguid = authData:sub(offset + 1, offset + 16)
   offset = offset + 16
   -- Credential ID Length (2 bytes)
   local rawIdLen = ba.socket.n2h(2, authData, offset + 1)
   offset = offset + 2
   -- Credential ID
   local rawId = authData:sub(offset + 1, offset + rawIdLen)
   offset = offset + rawIdLen
   -- Public Key (CBOR-encoded)
   local pubKeyCbor = authData:sub(offset + 1)
   local pubKeyData = cbor.decode(pubKeyCbor)
   -- Ensure Only P-256 Keys are Allowed
   -- pubKeyData[1] == 2 :  The key type is in the Elliptic Curve format.
   -- pubKeyData[3] == -7 : authenticator using ES256
   -- pubKeyData[-1] == 1 : curve type: P-256
   -- #pubKeyData[-2] : The x-coordinate of this public key
   -- #pubKeyData[-3] : The y-coordinate of this public key
   if not (pubKeyData[1] == 2 and pubKeyData[3] == -7 and pubKeyData[-1] == 1 and
           type(pubKeyData[-2]) == "string" and #pubKeyData[-2] == 32 and
              type(pubKeyData[-3]) == "string" and #pubKeyData[-3] == 32) then
      error("Invalid key type: Only P-256 is allowed!")
   end
   return {
      user=user,
      signatureCounter=signatureCounter,
      rawId=rawId,
      pubKey={
         x=pubKeyData[-2],
         y=pubKeyData[-3]
      }
   }
end

local function validateAuthenticatorData(self,cmd,authData,lastSignatureCounter)
   authData=b64dec(authData or "") or ""
   assert(#authData > 36, "authData too short")
   local offset = 0
   -- RP ID Hash (SHA-256, 32 bytes)
   local rpIdHash = authData:sub(offset + 1, offset + 32)
   offset = offset + 32
   -- Validate RP ID Hash
   local expectedRpIdHash = ba.crypto.hash("sha256")(rpId(self,cmd))(true,"binary")
   assert(rpIdHash == expectedRpIdHash,"RP ID hash mismatch")
   -- Flags (1 byte)
   local flags = authData:byte(offset + 1)
   offset = offset + 1
   -- Check User Presence (`UP` flag must be set)
   assert(0 ~= flags & 0x01,"User was not physically present!")
   -- Signature Counter (4 bytes, Big-Endian)
   local signatureCounter = ba.socket.n2h(4, authData, offset + 1)
   -- Validate Signature Counter (Must increase)
   if lastSignatureCounter and signatureCounter <= lastSignatureCounter then
      -- logic below: https://www.imperialviolet.org/2023/08/05/signature-counters.html
      if lastSignatureCounter ~= 0 or signatureCounter ~= 0 then
         error("Signature counter did not increase!")
      end
   end
   return {signatureCounter=signatureCounter,authenticatorData=authData}
end

local function validateAuthentication(self,cmd,data)
   local resp=data.response
   local username,clientDataJSON=validateClientDataJSON(self,cmd,resp.clientDataJSON,"get")
   local user=self._users[username]
   local rawId=b64dec(data.rawId)
   local auth=user[rawId] -- authenticator data
   local pubKey=auth.pubKey
   local ad=validateAuthenticatorData(self,cmd,resp.authenticatorData,auth.signatureCounter)
   auth.signatureCounter=ad.signatureCounter
   local signature = ba.b64decode(resp.signature or '')
   local hash=ba.crypto.hash("sha256")(ad.authenticatorData)(ba.crypto.hash("sha256")(clientDataJSON)(true,"binary"))(true,"binary")
   assert(true == ba.crypto.verify(signature,hash,{x=pubKey.x,y=pubKey.y}), "Signature verification fail")
   auth.lastUsedAt=now()
   return username,user,rawId
end


local function addUser(self,username,user)
   local users=self._users
   local existingUser=users[username]
   if existingUser then
      -- Merge new authenticator
      local rawId,auth=next(user)
      existingUser[rawId]=auth
   else
      users[username]=user
   end
end


-- Method webauth:quarantined
local function wa_quarantined(self,username)
   for url,q in pairs(self._quarantined) do
      if username==q[1] then return q[2],url end
   end
end


-- Method webauth:validate
local function wa_validate(self,url,cmd)
   local q=self._quarantined[url]
   if q then
      self._quarantined[url]=nil
      addUser(self,q[1],q[2])
      self._registered(q[1],cmd)
      return true
   end
end


local function parseJsonRequest(cmd)
   if "POST" == cmd:method() and "application/json" == cmd:header"Content-Type" then
      local jparser = ba.json.parser()
      local ok,table
      for data in cmd:rawrdr() do
         ok,table=jparser:parse(data)
         if not ok or table then break end
      end
      if ok and table then return table end
   end
   cmd:json{ok=false,msg="Invalidrequest"}
end


-----------------------------------------
-- Start REST API web-services functions

-- Arg cmd: request/response
local function finduser(self,cmd)
   local t=parseJsonRequest(cmd)
   if self._users[t.user] then
      cmd:json{ok=true}
   end
   local msg=wa_quarantined(self,t.user) and "quarantined" or "notfound"
   cmd:json{ok=false,msg=msg}
end

local function regoptions(self,cmd)
   local excludeCredentials
   local t=parseJsonRequest(cmd)
   local username=t.user
   if not username then cmd:json{ok=false,msg="Invalidrequest"} end
   local user=self._users[username]
   if user and next(user) then -- if we have existing authenticator(s)
      excludeCredentials={}
      for rawId in pairs(user) do
         table.insert(excludeCredentials,{type="public-key",id=b64enc(rawId)})
      end
   end

   cmd:json{
      rp={
         name=self._rp.name,
         id=rpId(self,cmd)
      },
      user={
         id=user2id(username),
         name=username,
         displayName=username
      },
      challenge=createChallenge(cmd,username),
      pubKeyCredParams={
         {type="public-key",alg=-7} -- SECP256R1
      },
      timeout=60000,
      excludeCredentials=excludeCredentials,
      authenticatorSelection= {
         residentKey="preferred",
         requireResidentKey=false,
         userVerification="preferred"
      },
      attestation="none"
   }
end


local function register(self,cmd)
   local accept,msg,url
   local ok,rsp=pcall(validateRegistration,self,cmd,parseJsonRequest(cmd))
   if ok then
      -- convert rsp (response) to authenticator stored in user object
      local username,rawId=rsp.user,rsp.rawId
      rsp.user,rsp.rawId=nil,nil
      -- rsp now: signatureCounter,pubKey
      rsp.createdAt=now()
      rsp.lastUsedAt=rsp.createdAt
      local user={[rawId]=rsp}
      local baseUrl=cmd:url():sub(1,-9) -- strip off 'register'
      repeat
         url=baseUrl.."r/"..bytesToHex(ba.rndbs(32))
      until not self._quarantined[url]
      ok,accept,msg=self._register(username,user,rawId,url)
      if ok then
         if not accept then
            local x,rUrl=wa_quarantined(self,username)
            if rUrl then self._quarantined[rUrl]=nil end -- Accept only one in quarantined
            self._quarantined[url]={username,user}
            cmd:json{ok=false,msg="quarantined"}
         end
         addUser(self,username,user)
         self._registered(username)
         if not msg then msg="" end
      end
   else
      self._loginerr(rsp)
   end
   cmd:json{ok=ok,msg=(msg or "webautherr")}
end

local function authoptions(self,cmd)
   local t=parseJsonRequest(cmd)
   local user=self._users[t.user]
   if user then
      local creds={}
      for rawId in pairs(user) do
         table.insert(creds,{type="public-key",id=b64enc(rawId)})
      end
      cmd:json{
         challenge=createChallenge(cmd,t.user),
         timeout=60000,
         id=rpId(self,cmd),
         userVerification="preferred", -- Recommended
         mediation="optional", -- Recommended
         allowCredentials=creds
      }
   end
   local msg=wa_quarantined(self,t.user) and "quarantined" or "notfound"
   cmd:json{ok=false,msg=msg}
end


local function authenticate(self,cmd)
   local msg
   local ok,username,user,rawId=pcall(validateAuthentication,self,cmd,parseJsonRequest(cmd))
   if ok then
      ok,msg=self._authenticate(cmd,username,user,rawId)
   else
      self._loginerr(username)
      msg="webautherr"
   end
   cmd:json{ok=ok,msg=msg}
end

local services={
   finduser=finduser,
   regoptions=regoptions,
   register=register,
   authoptions=authoptions,
   authenticate=authenticate,
}

-- REST API entry
local function webauth(self,cmd,relpath)
   if not cmd:initial() then return false end
   local rest=services[relpath] -- find REST service
   if rest then rest(self,cmd) end -- does not return
   if relpath:find("r/",1,true) then  -- possible validation request URL
      if self._wsBusy then cmd:senderror(404) return end
      local url=cmd:url()
      local q=self._quarantined[url]
      if q then
         wa_validate(self,url,cmd)
         if 0 == cmd:bytecount() then
            cmd:senderror(503,"No HTTP response from 'registered()' callback")
         end
      else -- brute force attack blocking logic
         self._wsBusy=true
         ba.timer(function() self._wsBusy=false end):set(3000,true)
         cmd:senderror(404)
      end
      return true
   end
   -- Else: REST service not found
   cmd:json{ok=false,msg="404"}
end

-- End REST API web-services functions
-----------------------------------------



local wa={quarantined=wa_quarantined}
wa.__index = wa

function wa:validate(url) return wa_validate(self,url) end

function wa:get() return self._users end

function wa:set(db) self._users=db end

local function create(op,o)
   assert("function"==type(op.register))
   assert("function"==type(op.registered))
   assert("function"==type(op.authenticate))
   o=setmetatable(o or {}, wa)
   o._register,o._registered,o._authenticate=op.register,op.registered,op.authenticate
   o._loginerr="function"==type(op.loginerr) or function(msg) tracep(false,10,"webauthn: "..msg) end
   o._rp={}
   o._rp.name=op.rp and op.rp.name or "Barracuda App Server"
   o._rp.id=op.rp and op.rp.id
   o._origin=op.origin
   o._users,o._quarantined={},{}
   local dir=ba.create.dir"webauthn"
   o._dir=dir
   dir:setfunc(function(env,relpath) return webauth(o,env.request,relpath) end)
   return o,dir
end

return {create=create}
