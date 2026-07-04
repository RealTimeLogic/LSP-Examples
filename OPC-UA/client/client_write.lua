local ua = require("opcua.api")

local Server_ServerStatus_StartTime = "i=2258"

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
  return
end

-- Open secure channel with timeout 120 seconds
resp, err = client:openSecureChannel(120000, ua.SecurityPolicy.None, ua.MessageSecurityMode.None)
if err ~= nil then
  return
end

resp, err = client:createSession("test_session", 3600000)
if err ~= nil then
  trace("Creating session failed: "..err)
  return
end

resp, err = client:activateSession()
if err ~= nil then
  return
end

-- Update the OPC-UA server's start time.
local nodes = {
  NodesToWrite = {
    {
      NodeId = Server_ServerStatus_StartTime,
      AttributeId = ua. AttributeId.Value,
      Value = {   -- DataValue
        Type = ua.VariantType.DateTime,
        Value = 0.0,
        StatusCode = ua.StatusCode.Good
      }
    }
  }
}

local resp,err = client:write(nodes)
if resp.Results[1] ~= 0 then
  trace(string.format("Changing attribute value failed: 0x%X", resp.Results[1]))
else
  trace(string.format("Attribute value changed sucessfully"))
end

client:disconnect()
