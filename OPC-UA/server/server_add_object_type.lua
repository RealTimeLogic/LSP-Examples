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

-- Add a structure type for the sensor data
local sensorDataType = modelEditor:addStructure("SensorDataType")
sensorDataType:addField("Temperature", ua.DataTypeId.Double, ua.ValueRank.Scalar)
sensorDataType:addField("Humidity", ua.DataTypeId.Double, ua.ValueRank.Scalar)
sensorDataType:addField("Precision", ua.DataTypeId.Enumeration, ua.ValueRank.Scalar)

-- Add a variable type for the sensor data
-- Variables of this type will have root node with structured value and
-- underlying hierarchy of fields will be expanded.
local sensorVariableDataType = modelEditor:addVariableType("SensorVariableDataType", nil, sensorDataType)

-- Add a sensor object type. This object type will be used
-- to create instances of sensors.
local sensorObjectType = modelEditor:addObjectType("SensorType")
-- Add a property to the sensor object type
local addressProp = sensorObjectType:addProperty("Address",
    {Type = ua.VariantType.Int32, Value = 1})
addressProp.Attrs.Description = {Text="Address of the sensor"}

-- Add a property to the sensor object type
local precisionProp = sensorObjectType:addProperty("Precision", nil, sensorDataEnum)
precisionProp.Attrs.Description = {Text="Precision of the sensor"}

-- Add a variable to the sensor object type
local sensorDataVariable = sensorObjectType:addVariable("Data", nil, sensorVariableDataType)
sensorDataVariable.Attrs.Description = {Text="Current measured sensor data"}

-- Add an object to the sensor object type
local busObject = sensorObjectType:addObject("Bus")
busObject.Attrs.Description = {Text="Ethernet bus object"}

-- Add an object to the sensor object type
local gpioFolder = sensorObjectType:addFolder("GPIO Pins")
gpioFolder:addVariable("GPIO 1", {Type = ua.VariantType.Int32, Value = 1})
gpioFolder:addVariable("GPIO 2", {Type = ua.VariantType.Int32, Value = 2})
gpioFolder:addVariable("GPIO 3", {Type = ua.VariantType.Int32, Value = 3})

-- Add a method to the sensor object type
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
local measureMethod = sensorObjectType:addMethod("Measure",
    measureSensor, inputArguments, outputArguments)
measureMethod.Attrs.Description = {Text="Measure the temperature of the sensor"}

local objectsFolder = modelEditor:objectsFolder()
local sensorFolder = objectsFolder:addFolder("Sensors")
local sensor1 = sensorFolder:addObject("Outside", sensorObjectType)
local sensor2 = sensorFolder:addObject("Inside", sensorObjectType)

-- Save the changes to the model
modelEditor:save()

-- Start the server and process incoming connections
server:run()

-- A few moments later... shutdown the server
server:shutdown()
