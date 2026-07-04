local ua = require("opcua.api")

local temperatureId = "ns=1;i=3001"
local setpointId = "ns=1;i=3002"

local config = {
  endpoints = {
    {
      endpointUrl = "opc.tcp://localhost:4843"
    }
  },

  securePolicies = {
    {
      securityPolicyUri = ua.SecurityPolicy.None
    }
  }
}

local server = ua.newServer(config)
server:initialize()

local editor = server.model:edit()
local tutorial = editor:objectsFolder():addFolder("Tutorial")

tutorial:addVariable("Temperature", {
  Type = ua.VariantType.Double,
  Value = 21.5
}, nil, temperatureId)

tutorial:addVariable("Setpoint", {
  Type = ua.VariantType.Double,
  Value = 24.0
}, nil, setpointId)

editor:save()

local resp = server:read({
  {
    NodeId = temperatureId,
    AttributeId = ua.AttributeId.Value
  }
})
assert(resp.Results[1].Value == 21.5)

trace("Added Temperature and Setpoint variables.")

server:run()
server:shutdown()
