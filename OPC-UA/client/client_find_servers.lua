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

-- Select known servers
local params = {
  EndpointUrl = "opc.tcp://localhost:4841"
}

local resp, err = client:findServers(params)
if err ~= nil then
  trace("Find servers error: "..err)
else
  if not resp.Servers[0] then
    trace("No servers found.")
  end
  for i,srv in ipairs(resp.Servers) do
    trace("server #"..i)
    trace("  "..srv.ApplicationUri)
    trace("  "..srv.ProductUri)
    trace("  "..srv.ApplicationName.Text)
  end
end

client:disconnect()
