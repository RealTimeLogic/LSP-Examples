local ua = require("opcua.api")

local counterId = "ns=1;i=5001"
local counter = {
  Type = ua.VariantType.UInt32,
  Value = 0,
  StatusCode = ua.StatusCode.Good
}

local config = {
  endpoints = {
    {
      endpointUrl = "opc.tcp://localhost:4845"
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
tutorial:addVariable("Counter", counter, nil, counterId)
editor:save()

server:setValueCallback(counterId, function(nodeId, newValue)
  if newValue then
    counter = newValue
    return
  end

  counter.Value = counter.Value + 1
  return counter
end)

local first = server:read({
  {
    NodeId = counterId,
    AttributeId = ua.AttributeId.Value
  }
})
local firstValue = first.Results[1].Value

local second = server:read({
  {
    NodeId = counterId,
    AttributeId = ua.AttributeId.Value
  }
})
assert(firstValue == 1)
assert(second.Results[1].Value == 2)

trace("Counter value is produced by a Lua callback.")

server:run()
server:shutdown()
