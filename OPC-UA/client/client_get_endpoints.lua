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

-- Connecting to OPCUA server
trace("connecting to server")
local endpointUrl = "opc.tcp://localhost:4841"
client:connect(endpointUrl)
if err ~= nil then
  trace("connection failed: "..err)
  return
end

-- Open secure channel with timeout 120 seconds
local resp, err = client:openSecureChannel(120000, ua.SecurityPolicy.None, ua.MessageSecurityMode.None)
if err ~= nil then
  trace("Opening secure channel failed: "..err)
end
trace("Opened secure channel with id: "..resp.SecurityToken.ChannelId)

-- Select endpoints
local params = {
  EndpointUrl = "opc.tcp://localhost:4841"
}

local resp, err = client:getEndpoints(params)
if err ~= nil then
  trace("Get endpoints error: "..err)
else
  if not resp.Endpoints[0] then
    trace("No endpoints found.")
  end
  for i,endpoint in ipairs(resp.Endpoints) do
    trace("enspoint #"..i)
    trace("  "..endpoint.EndpointUrl)
    trace("  "..endpoint.TransportProfileUri)
    trace("  "..endpoint.SecurityPolicyUri)
  end
end

client:disconnect()
