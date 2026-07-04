local ua = require("opcua.api")

local io = ba.openio("home")
mako.createloader(io)
local common = require("pubsub_common")

local brokerPort = 18891
local broker = common.createBroker(brokerPort)
local topic = "opcua/tutorial/json"
local transportProfileUri = ua.TranportProfileUri.MqttJson

local config = {
  bufSize = 8192
}

local subscriber = ua.newMqttClient(config)
local received
common.connectLocal(subscriber, broker, transportProfileUri)

subscriber:subscribe(topic, function(message, err)
  if err then
    common.fail("Failed to decode MQTT JSON PubSub message: " .. tostring(err))
  end
  received = message
end)

ba.sleep(300)

local publisher = ua.newMqttClient(config)
local datasetId = publisher:createDataset({
  { name = "Temperature" }
})

common.connectLocal(publisher, broker, transportProfileUri)
publisher:setValue(datasetId, "Temperature", {
  Type = ua.VariantType.Double,
  Value = 21.5
})
publisher:publish(topic, "tutorial-json")

common.waitFor("JSON PubSub message", function() return received ~= nil end)

local value = received.Messages[1].Payload.Temperature
assert(value.Type == ua.VariantType.Double)
assert(value.Value == 21.5)

publisher:close()
subscriber:close()
broker:shutdown()

trace("JSON PubSub message received and decoded.")
