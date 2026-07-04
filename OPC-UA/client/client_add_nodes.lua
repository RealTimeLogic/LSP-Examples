local ua = require("opcua.api")

local ObjectsFolder = "i=85"
local Organizes = "i=35"
local FolderType = "i=61"
local BaseDataVariableType = "i=63"
local UInt32 = "i=24"

local config = {
  bufSize = 65536,
  applicationName = 'RealTimeLogic example',
  applicationUri = "urn:opcua-lua:example",
  productUri = "urn:opcua-lua:example",
  securePolicies = {
    { -- #1
      securityPolicyUri = ua.SecurityPolicy.None
    }
  },
}

local client = ua.newClient(config)

local resp, err

-- Connecting to OPCUA server
trace("connecting to server")
local endpointUrl = "opc.tcp://localhost:4841"
err = client:connect(endpointUrl)
if err ~= nil then
  return
end

-- Open secure channel with timeout 120 seconds
resp, err = client:openSecureChannel(120000, ua.SecurityPolicy.None, ua.MessageSecurityMode.None)
if err ~= nil then
  return
end

resp, err = client:createSession("test_session", 3600000)
if err ~= nil then
  trace("Creating session failed: "..err)
  return
end

resp, err = client:activateSession()
if err ~= nil then
  return
end

local folderId = "i=1000"

-- Insert a folder into the address space
local folderParams = { -- #1
  ParentNodeId = ObjectsFolder,
  ReferenceTypeId = Organizes,
  RequestedNewNodeId = folderId,
  BrowseName = {Name="TestFolder", ns=0},
  NodeClass = ua.NodeClass.Object,
  TypeDefinition = FolderType,
  NodeAttributes = {
    TypeId = "i=354",
    Body = {
      SpecifiedAttributes = ua.ObjectAttributesMask,
      DisplayName = {Text="DisplayName"},
      Description = {Text="Description"},
      WriteMask = 0,
      UserWriteMask = 0,
      EventNotifier = 0,
    }
  }
}
local request = {
  NodesToAdd = {folderParams}
}
resp, err = client:addNodes(request)
for i,res in ipairs(resp.Results) do
  if res.StatusCode ~= 0 then
    trace(string.format("Adding folder node failed: 0x%X", res.StatusCode))
  else
    trace(string.format("Added new folder node with Id: '%s'", res.AddedNodeId))
  end
end

local variableId = "i=1000000"

local dataValue = {
  Type = ua.VariantType.UInt32,
  Value = 30000,
  StatusCode = ua.StatusCode.Good
}

local newVariable = ua.newVariableParams(ObjectsFolder, "UInt32", dataValue, variableId)

local request = {
  NodesToAdd = {newVariable}
}

resp, err = client:addNodes(request)
for i,res in ipairs(resp.results) do
  if res.statusCode ~= 0 then
    trace(string.format("Adding variable node failed: 0x%X", res.statusCode))
  else
    trace(string.format("Added new variable with NodeId: '%s'", res.addedNodeId))
  end
end


client:disconnect()
