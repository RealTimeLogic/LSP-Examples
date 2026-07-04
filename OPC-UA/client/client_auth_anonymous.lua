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
  trace("connection error: "..err)
  return
end

-- Open secure channel with timeout 120 seconds
local resp, err = client:openSecureChannel(120000, ua.SecurityPolicy.None, ua.MessageSecurityMode.None)
if err ~= nil then
  trace("Opening secure channel failed: "..err)
else
  trace("Opened secure channel with id: "..resp.SecurityToken.ChannelId)
end

-- Create session with name "test_session" and with life time
-- 1 hour (3600000 ms)
local session, err = client:createSession("test_session", 3600000)
local tokenPolicy
for _, endpoint in ipairs(session.ServerEndpoints) do
  for _, policy in ipairs(endpoint.UserIdentityTokens) do
    if  policy.TokenType == ua.UserTokenType.Anonymous
    then
      tokenPolicy = policy
      goto found
    end
  end
end

::found::
if not tokenPolicy then
  error("cannot find endpoint with anonymous token.")
end
-- Passing id of anonymous token policy.
local resp, err = client:activateSession(tokenPolicy.PolicyId)

client:disconnect()
