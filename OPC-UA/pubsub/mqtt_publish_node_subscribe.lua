local ua = require("opcua.api")

local io = ba.openio("home")
mako.createloader(io)
local common = require("pubsub_common")

local broker = common.createBroker(18881)
local dataTopic = "rtl/json/data/tutorial/server-node"
local transportProfileUri = ua.TranportProfileUri.MqttJson

local config = {
  bufSize = 8192
}

local uaServer = ua.newServer()
uaServer:initialize()

local objectsFolder = "i=85"
local request = {
  NodesToAdd = {
    ua.newVariableParams(objectsFolder, "MqttNode", {
      Type = ua.VariantType.UInt32,
      Value = 10
    })
  }
}

local resp = uaServer:addNodes(request)
local nodeId = resp.Results[1].AddedNodeId
assert(resp.Results[1].StatusCode == ua.StatusCode.Good)

local subscriber = ua.newMqttClient(config)
local received
common.connectLocal(subscriber, broker, transportProfileUri)

subscriber:subscribe(dataTopic, function(message, err)
  if err then
    common.fail("Failed to decode MQTT JSON PubSub message: " .. tostring(err))
  end
  received = message
end)

local publisher = ua.newMqttClient(config, uaServer)
publisher:createDataset({
  {
    nodeId = nodeId,
    name = "MqttNode"
  }
}, "5fa38ebb-44d2-a3ec-d251-1030c777f10a")

common.connectLocal(publisher, broker, transportProfileUri)

uaServer:run()

uaServer:write({
  NodesToWrite = {
    {
      NodeId = nodeId,
      AttributeId = ua.AttributeId.Value,
      Value = {
        Type = ua.VariantType.UInt32,
        Value = 123
      }
    }
  }
})

publisher:publish(dataTopic, "server-node-publisher")

common.waitFor("server node PubSub message", function()
  return received ~= nil
end)

local value = received.Messages[1].Payload.MqttNode
assert(value.Type == ua.VariantType.UInt32)
assert(value.Value == 123)

publisher:close()
subscriber:close()
uaServer:shutdown()
broker:shutdown()

trace("Published OPC UA server node value through local MQTT broker.")
