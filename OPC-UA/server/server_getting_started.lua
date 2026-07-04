-- Load the OPCUA API module
local ua = require("opcua.api")

-- Create new OPC UA server instance.
-- Pass configuration table to server.
local server = ua.newServer()

-- Initialize server.
server:initialize()

local ObjectsFolder = "i=85"

-- Add two variables:
--   1. Boolean scalar value
--   2. Boolean array value

-- required Node ID for variable
local scalarBooleanId = "i=1000000"

-- Initial boolean scalar value
local scalarBoolean = {
  Type = ua.VariantType.Boolean,
  Value = true
}

local arrBooleanId = "i=1000001"
-- Initial boolean array value
local arrBoolean = {
  Type = ua.VariantType.Boolean,
  IsArray = true,
  Value = {true, false, true, false}
}

local model = server.model:edit()
local objects = model:objectsFolder()
local folder = objects:addFolder("NewFolder")
folder:addVariable("Boolean", scalarBoolean, nil, scalarBooleanId)
folder:addVariable("BooleanArray", arrBoolean, nil, arrBooleanId)
model:save()

-- Start listening and dispatch incomming messages.
server:run()

-- Stop server.
server:shutdown()
