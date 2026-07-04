local ua = require("opcua.api")

local config = {
  applicationName = 'RealTimeLogic example',
  applicationUri = "urn:opcua-lua:example",
  productUri = "urn:opcua-lua:example",
  securePolicies = {
    { -- #1
      securityPolicyUri = ua.SecurityPolicy.None
    }
  },
}

local client = ua.newClient(config)

local resp, err

-- Connecting to OPCUA server
trace("connecting to server")
local endpointUrl = "opc.tcp://localhost:4841"
client:connect(endpointUrl, connectCallback)
if err ~= nil then
  trace("Connection failed: "..err)
  return
end

-- Open secure channel with timeout 120 seconds
resp, err = client:openSecureChannel(120000, ua.SecurityPolicy.None, ua.MessageSecurityMode.None)
if err ~= nil then
  trace("Open secure channel failed: "..err)
  return
end
trace("Opened secure channel with id: "..resp.SecurityToken.ChannelId)

resp, err = client:createSession("test_session", 3600000)
if err ~= nil then
  trace("Creating session failed: "..err)
  return
end

trace("created session:")
trace("  sessionId='"..resp.SessionId.."'")
trace("  authenticationToken='"..resp.AuthenticationToken.."'")
trace("  revisedSessionTimeout='"..resp.RevisedSessionTimeout.."'")

trace("Activating session:")
-- Newly created session must be activated
resp, err = client:activateSession()
if err ~= nil then
  trace("Activating session failed: "..err)
  return
end
trace("session activated")

resp, err = client:closeSession()
if err == nil then
  trace("Session closed")
end

client:disconnect()
