local ua = require("opcua.api")

local uaMqtt = ua.newMqttClient()

local fields = {
  { name = "Value1" },
  { name = "Value2" }
}

local transportProfileUri = ua.TranportProfileUri.MqttBinary
local endpointUrl = "opc.mqtt://test.mosquitto.org:1883"
uaMqtt:connect(endpointUrl, transportProfileUri)

local datasetId = uaMqtt:createDataset(fields)

local dataTopic = "rtl/uadp/data/urn:arykovanov-note:opcua:server/group/dataset"
local publisherId = "test_manual_publisher"

for i=64, 74 do
  uaMqtt:setValue(datasetId, "Value1", {Type=ua.VariantType.UInt32, Value=i})
  uaMqtt:setValue(datasetId, "Value2", {Type=ua.VariantType.UInt32, Value=i*2})
  uaMqtt:publish(dataTopic, publisherId)

  ba.sleep(1000)
end
