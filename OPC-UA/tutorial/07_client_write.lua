local ua = require("opcua.api")

local endpointUrl = "opc.tcp://localhost:4850"
local setpointId = "ns=1;i=7001"

local config = {
  applicationName = "Mako learning client",
  applicationUri = "urn:opcua-lua:mako-learning-client",
  productUri = "urn:opcua-lua:mako-learning-client",
  cosocketMode = false,
  socketTimeout = 10000,
  securePolicies = {
    {
      securityPolicyUri = ua.SecurityPolicy.None
    }
  }
}

local client = ua.newClient(config)
local err = client:connect(endpointUrl)
assert(err == nil, tostring(err))

local resp
resp, err = client:openSecureChannel(
  120000,
  ua.SecurityPolicy.None,
  ua.MessageSecurityMode.None
)
assert(err == nil, tostring(err))

resp, err = client:createSession("mako_learning_write", 120000)
assert(err == nil, tostring(err))

resp, err = client:activateSession()
assert(err == nil, tostring(err))

resp, err = client:write({
  NodesToWrite = {
    {
      NodeId = setpointId,
      AttributeId = ua.AttributeId.Value,
      Value = {
        Type = ua.VariantType.Double,
        Value = 25.25,
        StatusCode = ua.StatusCode.Good
      }
    }
  }
})
assert(err == nil, tostring(err))
assert(resp.Results[1] == ua.StatusCode.Good)

resp, err = client:read({
  NodesToRead = {
    {
      NodeId = setpointId,
      AttributeId = ua.AttributeId.Value
    }
  }
})
assert(err == nil, tostring(err))
assert(resp.Results[1].Value == 25.25)

trace("Client wrote Setpoint on the learning server.")

client:closeSession()
client:disconnect()
