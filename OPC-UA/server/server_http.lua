local ua = require("opcua.api")

local config = {
  endpoints = {
    {
      endpointUrl = "opc.http://localhost:9357/opcua",
    },
    {
      endpointUrl = "opc.https://localhost:9357/opcua",
    },
    {
      endpointUrl = "http://localhost:9357/opcua",
    },
    {
      endpointUrl = "https://localhost:9357/opcua",
    },
  },

  securePolicies = {
    { -- #1
      securityPolicyUri = ua.SecurityPolicy.None,
    },
  }
}

local server = ua.newServer(config)
server:initialize()
server:run()

local onRequest = server:createHttpDirectory()

--[[
The onRequest function should be called from an LSP page when an HTTP request is received.
The function is called with two arguments, the request and the response.

<?lsp

   server:onRequest(request, response)

?>
]]

server:shutdown()
