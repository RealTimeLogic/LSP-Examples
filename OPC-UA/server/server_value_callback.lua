-- require("ldbgmon").connect{client=false}

-- Load the required modules
local ua = require("opcua.api")

local ObjectsFolder = "i=85"

local config = {
  endpoints = {
    {
      endpointUrl = "opc.tcp://localhost:4845",
    }
  },

  securePolicies = {
   { -- #1
     securityPolicyUri = ua.SecurityPolicy.None,
   },
 },
}


local server = ua.newServer(config)
server:initialize()

local dataNodeId = "ns=1;i=1000001"
local deviceData = {
  Type = ua.VariantType.Int32,
  Value = 1
}

local request = {
    NodesToAdd = {
    ua.newVariableParams(ObjectsFolder, "device_data", deviceData, dataNodeId)
  }
}

local resp = server:addNodes(request)
for _,res in ipairs(resp.Results) do
  if res.StatusCode ~= ua.StatusCode.Good and res.StatusCode ~= ua.StatusCode.BadNodeIdExists then
    error(res.StatusCode)
  end
end

-- Callback that will be called for Read/Write operations
function callback(nodeId, newValue)
  if newValue ~= nil then
    -- writing data
    ua.printTable("newValue", newValue, trace)
    ua.printTable("deviceData", deviceData, trace)

    if newValue == nil then
      error(ua.StatusCode.BadInvalidArgument)
    end

    deviceData = newValue
  else
    -- reading data
    ua.printTable("read deviceData", deviceData, trace)
    return deviceData
  end
end

server:setValueCallback(dataNodeId, callback)

-- Read data from device
local attrs = server:read(dataNodeId)
ua.printTable("dataNodeId", attrs)

local nodes = {
  NodesToWrite = {
    {
      NodeId = dataNodeId,
      AttributeId = ua.AttributeId.Value,
      Value = {   -- DataValue
        Type = ua.VariantType.Int32,
        Value = 0,
        StatusCode = ua.StatusCode.Good
      }
    }
  }
}

local results = server:write(nodes)

server:run()
server:shutdown()
