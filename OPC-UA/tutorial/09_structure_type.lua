local ua = require("opcua.api")

local config = {
  endpoints = {
    {
      endpointUrl = "opc.tcp://localhost:4849"
    }
  },

  securePolicies = {
    {
      securityPolicyUri = ua.SecurityPolicy.None
    }
  }
}

local server = ua.newServer(config)
server:initialize()

local editor = server.model:edit()

local measurementType = editor:addStructure("MeasurementType")
measurementType:addField("Temperature", ua.DataTypeId.Double, ua.ValueRank.Scalar)
measurementType:addField("Humidity", ua.DataTypeId.Double, ua.ValueRank.Scalar)

local measurementVariableType = editor:addVariableType(
  "MeasurementVariableType",
  nil,
  measurementType
)

local tutorial = editor:objectsFolder():addFolder("Tutorial")
local measurement = tutorial:addVariable(
  "Measurement",
  nil,
  measurementVariableType,
  "ns=1;i=9001"
)
measurement.Attrs.Description = {
  Text = "Structured measurement value"
}

editor:save()

local fields = measurementType:getFields()
assert(#fields == 2)
assert(fields[1].Name == "Temperature")
assert(fields[2].Name == "Humidity")

trace("Added a custom structure and a variable type that uses it.")

server:run()
server:shutdown()
