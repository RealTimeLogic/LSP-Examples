-- Load the required modules
local ua = require("opcua.api")
local ObjectsFolder = "i=85"

local server = ua.newServer()
server:initialize()

local nsIndex = server:createNamespace("http://test.com")
print(nsIndex)

-- Create a new folder and variable in the new namespace
local folderNodeId = string.format("ns=%s;i=%s", nsIndex, 1000)
local variableNodeId = string.format("ns=%s;i=%s", nsIndex, 1001)

local dataValue = {
  Value = 100,
  Type = ua.VariantType.UInt32,
  StatusCode = ua.StatusCode.Good
}

-- Parameters of new folders and variables
local newNodeParams = {
  ua.newFolderParams(ObjectsFolder, "Values", folderNodeId),
  ua.newVariableParams(folderNodeId, "Temperature", dataValue, variableNodeId),
}

local request = {
  NodesToAdd = newNodeParams
}
local resp, err = server:addNodes(request)

if err then
  trace(string.format("Adding nodes failed: %s", err))
else
  for i,res in ipairs(resp.Results) do
    if res.StatusCode ~= 0 then
      trace(string.format("%i: Adding node failed: 0x%X", i, res.StatusCode))
    else
      trace(string.format("%i: Added node with Id: '%s'", i, res.AddedNodeId))
    end
  end
end

server:run()
server:shutdown()
