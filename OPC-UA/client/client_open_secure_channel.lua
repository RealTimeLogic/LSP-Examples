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
client:connect(endpointUrl)
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

client:disconnect()
