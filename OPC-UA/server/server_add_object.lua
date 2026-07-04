local ua = require("opcua.api")

local function fillAddressSpace(model)
  local editor = model:edit()

  local object = editor:addObject("Sensor")
  object:addVariable("Temperature", {Type=ua.VariantType.Double, Value=20})
  object:addVariable("Humidity", {Type=ua.VariantType.Double, Value=50})
  object:addVariable("Pressure", {Type=ua.VariantType.Double, Value=1013.25})
  object:addVariable("Voltage", {Type=ua.VariantType.Double, Value=220})
  object:addVariable("Current", {Type=ua.VariantType.Double, Value=10})
  object:addVariable("Power", {Type=ua.VariantType.Double, Value=2200})
  object:addVariable("Frequency", {Type=ua.VariantType.Double, Value=50})

  local configurationObject = object:addObject("Configuration")
  configurationObject:addProperty("Address", {Type=ua.VariantType.String, Value="1"})
  configurationObject:addProperty("Port", {Type=ua.VariantType.UInt16, Value=1234})
  configurationObject:addProperty("Enabled", {Type=ua.VariantType.Boolean, Value=true})

  local inputArguments = {
    {Name = "Address",  DataType = ua.DataTypeId.String},
    {Name = "Port",     DataType = ua.DataTypeId.UInt16},
    {Name = "Enabled",  DataType = ua.DataTypeId.Boolean},
  }

  local outputArguments = {
    {Name = "Result",  DataType = ua.DataTypeId.StatusCode},
  }

  local func = function(address, port, enabled)
    trace(string.format("New configuration: address=%s, port=%d, enabled=%s",
      address, port, enabled))

    return {
      {Name="Result", {Type = ua.DataTypeId.StatusCode, Value = ua.StatusCode.Good}}
    }
  end

  local method = object:addMethod("SetConfiguration",
    func, inputArguments, outputArguments)

  editor:save()
end

-- Create a new server
local server = ua.newServer()
fillAddressSpace(server.model)

-- Initialize the server, it becomes ready for customizations
server:initialize()
server:run()
server:shutdown()
