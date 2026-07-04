local ua = require("opcua.api")

local config = {
  endpoints = {
    {
      endpointUrl = "opc.tcp://localhost:4841"
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

trace("Server initialized with one opc.tcp endpoint.")

server:run()
server:shutdown()
