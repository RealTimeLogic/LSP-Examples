local ua = require("opcua.api")

-- Create MQTT client instance
local mqttClient = ua.newMqttClient()

-- Connect to MQTT broker
local function callbackCallback(status)
  ua.printTable("status", status)
end
mqttClient:connect("opc.mqtt://test.mosquitto.org:1883", callbackCallback)

-- The only message callback for both JSON and binary data
local function messageCallback(payload, err)
  if err then
    print("Error:" .. tostring(err))
  end
  ua.printTable("payload", payload)
end

-- Subscribe on a topic with binary data
mqttClient:subscribe("rtl/uadp/data/urn:arykovanov-note:opcua:server/group/dataset", messageCallback)
-- Subscribe on a topic with JSON data
mqttClient:subscribe("rtl/json/data/urn:arykovanov-note:opcua:server/group/dataset", messageCallback)

-- Wait for some time
local cnt=1
while cnt <= 3 do
   ba.sleep(1000)
   cnt = cnt+1
end
