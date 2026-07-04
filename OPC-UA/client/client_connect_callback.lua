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
  cosocketMode = true, -- Start socket read loop in separate cosocket
}

local done = false

local client = ua.newClient(config)
local function connectCallback(err)
  done = true
  if err ~= nil then
    trace("connection failed: "..err)
    return
  end
  trace("Connected sucessfully")
  client:disconnect()
end

local function connectToServer()
  trace("connecting to server")
  local endpointUrl = "opc.tcp://localhost:4841"
  client:connect(endpointUrl, connectCallback)
end

ba.socket.event(connectToServer, "s")

while done == false do
  ba.sleep(1)
end
