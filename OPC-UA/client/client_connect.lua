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
local endpointUrl = "opc.tcp://localhost:4841"
local err = client:connect(endpointUrl)
if err ~= nil then
  trace("connection failed: "..err)
else
  trace("Connected sucessfully")
end

client:disconnect()
