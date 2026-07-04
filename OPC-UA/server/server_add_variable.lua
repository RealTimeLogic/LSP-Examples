local ua = require("opcua.api")

-- Create a new server
local server = ua.newServer()
-- Initialize the server, it becomes ready for customizations
server:initialize()

local modelEditor = server.model:edit()

-- Add a variable for the sensor data
local objectsFolder = modelEditor:objectsFolder()

local sensorDataVariable = objectsFolder:addVariable("SensorData")
sensorDataVariable:addVariable("Temperature",
    {Type = ua.VariantType.Double, Value = 20})

sensorDataVariable:addVariable("Humidity",
    {Type = ua.VariantType.Double, Value = 50})

-- Save the changes to the model
modelEditor:save()

-- Start the server and process incoming connections
server:run()

-- A few moments later... shutdown the server
server:shutdown()
