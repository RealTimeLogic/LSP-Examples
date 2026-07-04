local ua = require("opcua.api")

local io = ba.openio("home")
mako.createloader(io)
local common = require("pubsub_common")

local broker = common.createBroker(18882)
local dataTopic = "rtl/uadp/data/tutorial/manual"
local transportProfileUri = ua.TranportProfileUri.MqttBinary

local config = {
  bufSize = 8192
}

local subscriber = ua.newMqttClient(config)
local messages = {}
common.connectLocal(subscriber, broker, transportProfileUri)

subscriber:subscribe(dataTopic, function(message, err)
  if err then
    common.fail("Failed to decode MQTT binary PubSub message: " .. tostring(err))
  end
  table.insert(messages, message)
end)

local publisher = ua.newMqttClient(config)
local datasetId = publisher:createDataset({
  { name = "Value1" },
  { name = "Value2" }
})

common.connectLocal(publisher, broker, transportProfileUri)

local publisherId = "manual-publisher"

for i = 1, 3 do
  publisher:setValue(datasetId, "Value1", {
    Type = ua.VariantType.UInt32,
    Value = i
  })
  publisher:setValue(datasetId, "Value2", {
    Type = ua.VariantType.UInt32,
    Value = i * 2
  })
  publisher:publish(dataTopic, publisherId)
end

common.waitFor("manual PubSub messages", function()
  return #messages == 3
end)

for i = 1, 3 do
  local fields = messages[i].Messages[1].Fields
  assert(fields[1].Value.Value == i)
  assert(fields[2].Value.Value == i * 2)
end

publisher:close()
subscriber:close()
broker:shutdown()

trace("Published manual binary PubSub values through local MQTT broker.")
