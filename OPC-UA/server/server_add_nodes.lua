local ua = require("opcua.api")

-- Object folder node id
local ObjectsFolder = "i=85"

-- Create a new server
local server = ua.newServer()
-- Initialize the server, it becomes ready for customizations
server:initialize()

local modelEditor = server.model:edit()
-- Get ObjectsFolder node
local objectsFolder = modelEditor:objectsFolder()
-- Create to node folders and add some variables to them
local folder1 = objectsFolder:addFolder("Folder1")
-- Add a variable to the folder
local variable1 = folder1:addVariable("Variable1", {
  Type = ua.VariantType.UInt32,
  Value=40000,
})
-- Add another variable to the folder
local folder2 = objectsFolder:addFolder("Folder2")
local variable2 = folder2:addVariable("Variable2", {
  Type = ua.VariantType.String,
  Value="Hello",
})

-- Save the changes to the model
modelEditor:save()

-- Start the server and process incoming connections
server:run()

-- A few moments later... shutdown the server
server:shutdown()
