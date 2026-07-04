local ua = require("opcua.api")

-- Object folder node id
local ObjectsFolder = "i=85"

-- Create a new server
local server = ua.newServer()
-- Initialize the server, it becomes ready for customizations
server:initialize()

local modelEditor = server.model:edit()
local objectsFolder = modelEditor:objectsFolder()
local sensorObject = objectsFolder:addObject("Sensor")

-- Add a method to measure the temperature of the sensor
local function measureSensor(objectId, methodId, isAsync)
  if isAsync then
    return ua.StatusCode.Good
  end

  return ua.StatusCode.Good
end
local inputArguments = {
  {Name = "IsAsync",  DataType = ua.DataTypeId.Boolean},
}
local outputArguments = {
  {Name = "Status",  DataType = ua.DataTypeId.StatusCode},
}
local measureMethod = sensorObject:addMethod("Measure",
    measureSensor, inputArguments, outputArguments)
measureMethod.Attrs.Description = {Text="Measure the temperature of the sensor"}

local inputArguments = {
  {Name = "IsAsync",  DataType = ua.DataTypeId.Boolean},
  {Name = "Unit",  DataType = ua.DataTypeId.String},
}
measureMethod:setInputArguments(inputArguments)

local outputArguments = {
  {Name = "Status",  DataType = ua.DataTypeId.StatusCode},
  {Name = "Temperature",  DataType = ua.DataTypeId.Double},
}
measureMethod:setOutputArguments(outputArguments)

-- Save the changes to the model
modelEditor:save()

-- Start the server and process incoming connections
server:run()

-- A few moments later... shutdown the server
server:shutdown()
