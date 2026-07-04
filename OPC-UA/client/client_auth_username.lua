local ua = require("opcua.api")

local config = {
  applicationName = 'RealTimeLogic example',
  applicationUri = "urn:opcua-lua:example",
  productUri = "urn:opcua-lua:example",
  securePolicies = {
    { -- #1
      securityPolicyUri = ua.SecurityPolicy.None
    }
  }
}

local client = ua.newClient(config)

-- Connecting to OPCUA server
trace("connecting to server")
local endpointUrl = "opc.tcp://localhost:4841"
local err = client:connect(endpointUrl)
if err ~= nil then
  error("connection error: "..err)
  return
end

-- Open secure channel with timeout 120 seconds
local resp, err = client:openSecureChannel(120000, ua.SecurityPolicy.None, ua.MessageSecurityMode.None)
if err ~= nil then
  error("Opening secure channel failed: "..err)
end

-- Create session with name "test_session" and with life time
-- 1 hour (3600000 ms)
local session, err = client:createSession("test_session", 3600000)
if err ~= nil then
  error("Creating session failed: "..err)
end

local tokenPolicy
for _, endpoint in ipairs(session.ServerEndpoints) do
  for _, policy in ipairs(endpoint.UserIdentityTokens) do
    if policy.TokenType == ua.UserTokenType.UserName and
      (policy.SecurityPolicyUri == nil or policy.SecurityPolicyUri == ua.SecurityPolicy.None)
    then
      tokenPolicy = policy
      goto found
    end
  end
end

::found::
if not tokenPolicy then
  error("cannot find endpoint with username token.")
end

local userName = "admin"
local password = "12345"
local resp, err = client:activateSession(tokenPolicy.PolicyId, userName, password)
if err ~= nil then
  error("Activating session failed: "..err)
end

client:disconnect()
