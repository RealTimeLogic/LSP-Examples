local ua = require("opcua.api")

local endpointUrl = "opc.tcp://localhost:4850"
local controllerId = "ns=1;i=8001"
local methodId = "ns=1;i=8002"

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

resp, err = client:createSession("mako_learning_call", 120000)
assert(err == nil, tostring(err))

resp, err = client:activateSession()
assert(err == nil, tostring(err))

resp, err = client:call(controllerId, methodId, {
  {Type = ua.VariantType.Double, Value = 10.0},
  {Type = ua.VariantType.Double, Value = 2.5}
})
assert(err == nil, tostring(err))
assert(resp.Results[1].StatusCode == ua.StatusCode.Good)
assert(resp.Results[1].OutputArguments[1].Value == 25.0)

trace("Client called ScaleValue on the learning server.")

client:closeSession()
client:disconnect()
