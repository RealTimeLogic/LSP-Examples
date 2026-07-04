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
trace("connecting to server")
local err = client:connect("opc.https://localhost:"..mako.sslport.."/opcua/")
if err ~= nil then
  error("connection failed: "..err)
end

trace("Connected sucessfully")

-- Open secure channel with timeout 120 seconds
local resp, err = client:openSecureChannel(120000, ua.SecurityPolicy.None, ua.MessageSecurityMode.None)
if err ~= nil then
  error("Opening secure channel failed: "..err)
end

local resp, err = client:getEndpoints()
if err ~= nil then
  error("Get endpoints error: "..err)
end

if not resp.Endpoints[0] then
  trace("No endpoints found.")
end

for i,endpoint in ipairs(resp.Endpoints) do
  trace("endpoint #"..i)
  trace("  "..endpoint.EndpointUrl)
  trace("  "..endpoint.TransportProfileUri)
  trace("  "..endpoint.SecurityPolicyUri)
end

client:disconnect()
