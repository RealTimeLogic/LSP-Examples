local ua = require("opcua.api")

local io = ba.openio("home")
mako.createloader(io)
local common = require("pubsub_common")

local brokerPort = 18892
local broker = common.createBroker(brokerPort)
local topic = "opcua/tutorial/uadp"
local transportProfileUri = ua.TranportProfileUri.MqttBinary

local config = {
  bufSize = 8192
}

local subscriber = ua.newMqttClient(config)
local received
common.connectLocal(subscriber, broker, transportProfileUri)

subscriber:subscribe(topic, function(message, err)
  if err then
    common.fail("Failed to decode MQTT binary PubSub message: " .. tostring(err))
  end
  received = message
end)

ba.sleep(300)

local publisher = ua.newMqttClient(config)
local datasetId = publisher:createDataset({
  { name = "Speed" },
  { name = "State" }
})

common.connectLocal(publisher, broker, transportProfileUri)
publisher:setValue(datasetId, "Speed", {
  Type = ua.VariantType.UInt32,
  Value = 1200
})
publisher:setValue(datasetId, "State", {
  Type = ua.VariantType.Boolean,
  Value = true
})
publisher:publish(topic, "tutorial-binary")

common.waitFor("binary PubSub message", function() return received ~= nil end)

local fields = received.Messages[1].Fields
assert(fields[1].Index == 1)
assert(fields[1].Value.Type == ua.VariantType.UInt32)
assert(fields[1].Value.Value == 1200)
assert(fields[2].Index == 2)
assert(fields[2].Value.Type == ua.VariantType.Boolean)
assert(fields[2].Value.Value == true)

publisher:close()
subscriber:close()
broker:shutdown()

trace("Binary PubSub message received and decoded.")
