local ua = require("opcua.api")

local io = ba.openio("home")
mako.createloader(io)
local common = require("pubsub_common")

local brokerPort = 18893
local broker = common.createBroker(brokerPort)
local topic = "opcua/tutorial/server-node"
local transportProfileUri = ua.TranportProfileUri.MqttJson
local variableId = "ns=1;s=TutorialLevel"

local config = {
  bufSize = 8192
}

local server = ua.newServer({
  endpoints = {
    {
      endpointUrl = "opc.tcp://localhost:4846"
    }
  },

  securePolicies = {
    {
      securityPolicyUri = ua.SecurityPolicy.None
    }
  }
})

server:initialize()

local editor = server.model:edit()
local tutorial = editor:objectsFolder():addFolder("TutorialPubSub")
tutorial:addVariable("Level", {
  Type = ua.VariantType.UInt32,
  Value = 1
}, nil, variableId)
editor:save()

server:run()

local subscriber = ua.newMqttClient(config)
local received
common.connectLocal(subscriber, broker, transportProfileUri)

subscriber:subscribe(topic, function(message, err)
  if err then
    common.fail("Failed to decode MQTT server-node message: " .. tostring(err))
  end
  received = message
end)

ba.sleep(300)

local publisher = ua.newMqttClient(config, server)
local datasetId = publisher:createDataset({
  {
    nodeId = variableId,
    name = "Level"
  }
})

common.connectLocal(publisher, broker, transportProfileUri)

server:write({
  NodesToWrite = {
    {
      NodeId = variableId,
      AttributeId = ua.AttributeId.Value,
      Value = {
        Type = ua.VariantType.UInt32,
        Value = 42
      }
    }
  }
})

publisher:publish(topic, "tutorial-server-node")

common.waitFor("server-node PubSub message", function() return received ~= nil end)

local value = received.Messages[1].Payload.Level
assert(value.Type == ua.VariantType.UInt32)
assert(value.Value == 42)

publisher:close()
subscriber:close()
server:shutdown()
broker:shutdown()

trace("Server node value published through MQTT PubSub.")
