local ua = require("opcua.api")

local setpointId = "ns=1;i=4001"

local config = {
  endpoints = {
    {
      endpointUrl = "opc.tcp://localhost:4844"
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
tutorial:addVariable("Setpoint", {
  Type = ua.VariantType.Double,
  Value = 24.0
}, nil, setpointId)
editor:save()

local writeResp = server:write({
  NodesToWrite = {
    {
      NodeId = setpointId,
      AttributeId = ua.AttributeId.Value,
      Value = {
        Type = ua.VariantType.Double,
        Value = 26.5,
        StatusCode = ua.StatusCode.Good
      }
    }
  }
})
assert(writeResp.Results[1] == ua.StatusCode.Good)

local readResp = server:read({
  {
    NodeId = setpointId,
    AttributeId = ua.AttributeId.Value
  }
})
assert(readResp.Results[1].Value == 26.5)

trace("Wrote Setpoint from server-side Lua.")

server:run()
server:shutdown()
