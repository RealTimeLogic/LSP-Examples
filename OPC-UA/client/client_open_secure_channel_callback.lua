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
  cosocketMode = true, -- Start socket read loop in a separate cosocket.
}

local done = false

local client = ua.newClient(config)

local function onChannelOpened(resp, err)
  if err ~= nil then
    trace("Secure channel error: "..tostring(err))
    return
  end
  trace("Opened secure channel with id: "..resp.SecurityToken.ChannelId)
  done = true
end

local function connectCallback(err)
  if err == nil then
    local secureChannelTimeout = 60000 -- ms
    client:openSecureChannel(secureChannelTimeout, ua.SecurityPolicy.None, ua.MessageSecurityMode.None, nil, onChannelOpened)
  end
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

client:disconnect()
