local ua = require("opcua.api")

-- create server
local uaServer = ua.newServer()
uaServer:initialize()

local ObjectsFolder = "i=85"
local int32DataValue = {
  Type = ua.VariantType.UInt32,
  Value = 10
}
local request = {
  NodesToAdd = {ua.newVariableParams(ObjectsFolder, "writeHook", int32DataValue)}
}

-- Add a node
local resp = uaServer:addNodes(request)
local results = resp.Results
assert(results[1].StatusCode, ua.StatusCode.Good)
local nodeId =  results[1].AddedNodeId

-- Create MQTT client
local config = {
  bufSize = 128 -- max size of MQTT message
}

local uaMmqtt = ua.newMqttClient(config, uaServer)

-- Array with fields parameters.
local fields = {
  -- #1
  {
    nodeId = nodeId,   -- ID of the node whose changes will be monitored
    name = "MqttNode", -- Field name used in JSON payloads
  }
}

-- create dataset with fields
local classId = "5fa38ebb-44d2-a3ec-d251-1030c777f10a"
uaMmqtt:createDataset(fields, classId)

-- Connect to MQTT broker
local transportProfileUri = ua.TranportProfileUri.MqttJson
local endpointUrl = "opc.mqtt://test.mosquitto.org:1883"
uaMmqtt:connect(endpointUrl, transportProfileUri)

-- Start periodic publishing
local dataTopic = "rtl/json/data/urn:arykovanov-note:opcua:server/group/dataset"
uaMmqtt:startPublishing(dataTopic, "test_cyclic_publisher", 2000)

-- Run server.
uaServer:run()

-- Function which will periodically write data to address space
-- Those changes will be hooked by MQTT client for publishing data.
local writeRequest = {
  NodesToWrite = {
    {
      NodeId = nodeId,
      AttributeId = ua.AttributeId.Value,
      Value = {
        Type = ua.VariantType.UInt32,
        Value=123
      }
    }
  }
}


uaServer:write(writeRequest)

uaMmqtt:stopPublishing()
uaServer:shutdown()
