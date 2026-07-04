local ua = require("opcua.api")

-- Create a new server
local server = ua.newServer()
-- Initialize the server, it becomes ready for customizations
server:initialize()

local modelEditor = server.model:edit()

-- Add a structure type for the sensor data
local sensorDataType = modelEditor:addStructure("SensorDataType")
sensorDataType:addField("Temperature", ua.DataTypeId.Double, ua.ValueRank.Scalar)
sensorDataType:addField("Humidity", ua.DataTypeId.Double, ua.ValueRank.Scalar)
sensorDataType:addField("Precision", ua.DataTypeId.Enumeration, ua.ValueRank.Scalar)

local allFields = sensorDataType:getFields()
for _, field in ipairs(allFields) do
  print(field.Name, field.DisplayName, field.DataType, field.ValueRank, field.IsOptional)
end

local fields = {
  {
    Name = "Temperature",
    DisplayName = {Text = "Temperature"},
    DataType = ua.DataTypeId.Double,
    ValueRank = ua.ValueRank.Scalar,
    IsOptional = false
  },
  {
    Name = "Humidity",
    DisplayName = {Text = "Humidity"},
    DataType = ua.DataTypeId.Double,
    ValueRank = ua.ValueRank.Scalar,
    IsOptional = false
  },
  {
    Name = "Precision",
    DisplayName = {Text = "Precision"},
    DataType = ua.DataTypeId.Enumeration,
    ValueRank = ua.ValueRank.Scalar,
    IsOptional = false
  },
}
sensorDataType:setFields(fields)

local field = sensorDataType:getField("Precision")
print(field.Name, field.DisplayName, field.DataType, field.ValueRank, field.IsOptional)

-- Add a variable type for the sensor data
-- Variables of this type will have root node with structured value and underlying hierarchy of fields will be expanded.
local sensorVariableDataType = modelEditor:addVariableType("SensorVariableDataType", nil, sensorDataType)

-- Add a variable to the sensor object type
local objectsFolder = modelEditor:objectsFolder()
local sensorDataVariable = objectsFolder:addVariable("Data", nil, sensorVariableDataType)
sensorDataVariable.Attrs.Description = {Text="Current measured sensor data"}

-- Save the changes to the model
modelEditor:save()

-- Start the server and process incoming connections
server:run()

-- A few moments later... shutdown the server
server:shutdown()
