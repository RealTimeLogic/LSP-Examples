local ua = require("opcua.api")

local config = {
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
client:connect(endpointUrl)
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


local ObjectsFolder = "i=85"
local TypesFolder = "i=86"

-- Read all possible attributes of the any node
-- For part of attributes will be returned a valus
-- and for part of attributes will be returned a status code BadAttributeIdInvalid
resp,err = client:read(ObjectsFolder)
for i,result in ipairs(resp.Results) do
  if result.StatusCode == 0 then
    ua.printTable("result", result.Value)
  else
    trace(string.format("Read attributes error: 0x%X", result.StatusCode))
  end
end

-- Read all possible attributes of several nodes
-- For part of attributes will be returned a valus
-- and for part of attributes will be returned a status code BadAttributeIdInvalid
resp,err = client:read({ObjectsFolder, TypesFolder})
for i,result in ipairs(resp.Results) do
  if result.StatusCode == 0 then
    ua.printTable("result", result.Value)
  else
    trace(string.format("Read value error: 0x%X", result.StatusCode))
  end
end

-- Reading current time on server and product version.
local Server_ServerStatus_CurrentTime = "i=2258"
local Server_ServerStatus_BuildInfo_SoftwareVersion = "i=2260"

local readParams = {
  NodesToRead = {
    {
      NodeId = Server_ServerStatus_CurrentTime,
      AttributeId = ua.AttributeId.Value
    },
    {
      NodeId = Server_ServerStatus_BuildInfo_SoftwareVersion,
      AttributeId = ua.AttributeId.Value
    },
  }
}

resp,err = client:read(readParams)
for i,result in ipairs(resp.Results) do
  if result.StatusCode == 0 then
    ua.printTable("result", result.Value)
  else
    trace(string.format("Read value '%s' error: 0x%X", nodes.NodesToRead[i].NodeId, result.StatusCode))
  end
end

client:closeSession()
client:disconnect()
