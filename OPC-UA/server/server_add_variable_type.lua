local ua = require("opcua.api")

-- Create a new server
local server = ua.newServer()
-- Initialize the server, it becomes ready for customizations
server:initialize()

local modelEditor = server.model:edit()

-- Add a variable type for the sensor data
-- Variables of this type will have root node with structured value and underlying hierarchy of fields will be expanded.
local sensorVariableDataType = modelEditor:addVariableType("SensorVariableType")
sensorVariableDataType:addVariable("Temperature",
    {Type = ua.VariantType.Double, Value = 20})

sensorVariableDataType:addVariable("Humidity",
    {Type = ua.VariantType.Double, Value = 50})

local objectsFolder = modelEditor:objectsFolder()
local sensor1 = objectsFolder:addVariable("Outside", nil,sensorVariableDataType)
local sensor2 = objectsFolder:addVariable("Inside", nil, sensorVariableDataType)

-- Save the changes to the model
modelEditor:save()

-- Start the server and process incoming connections
server:run()

-- A few moments later... shutdown the server
server:shutdown()
