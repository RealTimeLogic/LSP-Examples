local ua = require("opcua.api")

local function readFile(path)
  local f = _G.io.open(path, "rb")
  if not f then
    return nil
  end

  local data = f:read("*a")
  f:close()
  return data
end

local function loadCerts()
  local candidates = {
    "certs",
    mako.cfgdir and mako.cfgdir.."/certs" or nil,
  }

  for _, dir in ipairs(candidates) do
    if dir then
      local certificate = readFile(dir.."/client.pem")
      local key = readFile(dir.."/client.key")
      if certificate and key then
        return certificate, key
      end
    end
  end

  error("cannot find client certificate files")
end

local clientCertificate, clientKey = loadCerts()

local config = {
  applicationName = 'RealTimeLogic example',
  applicationUri = "urn:opcua-lua:example",
  productUri = "urn:opcua-lua:example",

  io = _G.io,
  certificate = clientCertificate,
  key =         clientKey,

  securePolicies = {
    { -- #1
      securityPolicyUri = ua.SecurityPolicy.None
    },
    { -- #2
      securityPolicyUri = ua.SecurityPolicy.Basic128Rsa15,
      securityMode = ua.MessageSecurityMode.SignAndEncrypt,
    }
  }
}

local client = ua.newClient(config)

-- Connecting to OPCUA server
trace("connecting to server")
local endpointUrl = "opc.tcp://localhost:4841"
local err = client:connect(endpointUrl)
if err ~= nil then
  trace("connection error: "..err)
  return
end

-- Open secure channel with timeout 120 seconds
local resp, err = client:openSecureChannel(120000, ua.SecurityPolicy.None, ua.MessageSecurityMode.None)
if err ~= nil then
  error("Opening secure channel failed: "..err)
end

local session, err = client:createSession("test_session", 3600000)
local tokenPolicy
for _, endpoint in ipairs(session.ServerEndpoints) do
  for _, policy in ipairs(endpoint.UserIdentityTokens) do
    -- Select JWT token policy. There also Azure, OAuth2 and OPCUA.
    if  policy.TokenType == ua.UserTokenType.IssuedToken and
        policy.IssuedTokenType == ua.IssuedTokenType.JWT
    then
      tokenPolicy = policy
      goto found
    end
  end
end

::found::
if not tokenPolicy then
  error("cannot find endpoint with certificate token policy.")
end

local jwtHeader = { alg="HS256"}
local jwtPayload = {
  sub = "1234567890",
  name = "John Doe",
  iat = 1516239022
}
local token = require"jwt".sign("my-secret", jwtPayload, jwtHeader)
local resp, err = client:activateSession(tokenPolicy.PolicyId, token)
if err ~= nil then
  error("Activating session failed: "..err)
end

local resp, err = client:closeSession()
local resp, err = client:closeSecureChannel()

client:disconnect()




