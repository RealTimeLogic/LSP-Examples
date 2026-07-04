local ua = require("opcua.api")

local io = ba.openio("home")
mako.createloader(io)
local common = require("pubsub_common")

local broker = common.createBroker(18883)
local jsonTopic = "rtl/json/data/tutorial/subscribe"
local binaryTopic = "rtl/uadp/data/tutorial/subscribe"

local config = {
  bufSize = 8192
}

local jsonSubscriber = ua.newMqttClient(config)
local binarySubscriber = ua.newMqttClient(config)
local receivedJson
local receivedBinary

common.connectLocal(jsonSubscriber, broker, ua.TranportProfileUri.MqttJson)
common.connectLocal(binarySubscriber, broker, ua.TranportProfileUri.MqttBinary)

jsonSubscriber:subscribe(jsonTopic, function(message, err)
  if err then
    common.fail("Failed to decode JSON MQTT PubSub message: " .. tostring(err))
  end
  receivedJson = message
end)

binarySubscriber:subscribe(binaryTopic, function(message, err)
  if err then
    common.fail("Failed to decode binary MQTT PubSub message: " .. tostring(err))
  else
    receivedBinary = message
  end
end)

local jsonPublisher = ua.newMqttClient(config)
local jsonDatasetId = jsonPublisher:createDataset({
  { name = "JsonValue" }
})
common.connectLocal(jsonPublisher, broker, ua.TranportProfileUri.MqttJson)
jsonPublisher:setValue(jsonDatasetId, "JsonValue", {
  Type = ua.VariantType.String,
  Value = "json-message"
})
jsonPublisher:publish(jsonTopic, "json-publisher")

local binaryPublisher = ua.newMqttClient(config)
local binaryDatasetId = binaryPublisher:createDataset({
  { name = "BinaryValue" }
})
common.connectLocal(binaryPublisher, broker, ua.TranportProfileUri.MqttBinary)
binaryPublisher:setValue(binaryDatasetId, "BinaryValue", {
  Type = ua.VariantType.UInt32,
  Value = 456
})
binaryPublisher:publish(binaryTopic, "binary-publisher")

common.waitFor("JSON and binary PubSub messages", function()
  return receivedJson ~= nil and receivedBinary ~= nil
end)

assert(receivedJson.Messages[1].Payload.JsonValue.Value == "json-message")
assert(receivedBinary.Messages[1].Fields[1].Value.Value == 456)

jsonPublisher:close()
binaryPublisher:close()
jsonSubscriber:close()
binarySubscriber:close()
broker:shutdown()

trace("Subscribed to JSON and binary MQTT PubSub messages from local broker.")
