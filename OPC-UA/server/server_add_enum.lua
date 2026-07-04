local ua = require("opcua.api")

-- Object folder node id
local ObjectsFolder = "i=85"

-- Create a new server
local server = ua.newServer()
-- Initialize the server, it becomes ready for customizations
server:initialize()

local modelEditor = server.model:edit()

-- Add enum for the sensor data
local sensorDataEnum = modelEditor:addEnum("PrecisionType", {
  "Low",
  "Medium",
  "High",
})

local values = sensorDataEnum:getValues()
for i, value in ipairs(values) do
  print(value)
end

-- Add a new value to the enum
sensorDataEnum:setValues({"Low", "Medium", "High", "VeryHigh"})

-- Save the changes to the model
modelEditor:save()

-- Start the server and process incoming connections
server:run()

-- A few moments later... shutdown the server
server:shutdown()
