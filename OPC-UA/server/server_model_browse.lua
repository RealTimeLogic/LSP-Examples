-- Load the required modules
local ua = require("opcua.api")

local print = trace and trace or print

local server = ua.newServer()
server:initialize()

-- Adrress space model manages address space nodes and references.
local model = server.model

-- Get the objects folder node with id i=85
local objectsFolder = model:browse():objectsFolder()
print(objectsFolder.Attrs.BrowseName.Name) -- "Objects"
print(objectsFolder.Attrs.NodeId) -- "i=85"

-- Resolve path to the objects folder node with id i=85
local objectsFolderPath = model:browse():path("Objects")
print(objectsFolderPath.Attrs.BrowseName.Name) -- "Objects"
print(objectsFolderPath.Attrs.NodeId) -- "i=85"

-- Resolve path to the server object node
local serverObject = model:browse():path({"Objects", "Server"})
print(serverObject.Attrs.BrowseName.Name) -- "Server"
print(serverObject.Attrs.NodeId) -- "i=2253"

-- Resolve path to server object type definition node
-- it is possible to mix string and table in the path:
--   * for strings it will browsed hierarhical references
--   * for tables it will browsed references by the ReferenceTypeId
local serverObjectTypeDefinition = model:browse():path({
  "Objects", -- #1
  "Server",  -- #2
  {          -- #3
    TargetName = "ServerType", -- This is either a strinf or a QualifiedName
    ReferenceTypeId = ua.ReferenceType.HasTypeDefinition,
    IncludeSubtypes = false,
    IsInverse = false,
  }
})

print(serverObjectTypeDefinition.Attrs.BrowseName.Name) -- "ServerType"
print(serverObjectTypeDefinition.Attrs.NodeId) -- "i=2253"

-- Resolve path to the server type node which is a type of server object instance
local serverType = model:browse():path({"Types", "ObjectTypes", "BaseObjectType", "ServerType"})
print(serverType.Attrs.BrowseName.Name) -- "ServerType"
print(serverType.Attrs.NodeId) -- "i=2253"

-- Resolve path to the server type node which is a type of server object instance
local serverType = model:browse():typesFolder():path({
  "ObjectTypes",
  "BaseObjectType",
  "ServerType"
})
print(serverType.Attrs.BrowseName.Name) -- "ServerType"
print(serverType.Attrs.NodeId) -- "i=2253"

server:run()
server:shutdown()
