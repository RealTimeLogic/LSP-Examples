-- require("ldbgmon").connect{client=false}

-- Load the required modules
local ua = require("opcua.api")
local nodeIds = require("tests.node_ids")

-- Function for validating user credentials sent by client
-- inside token
local function authenticate(tokenType)

  if tokenType == "anonymous" then
    return true
  end

  return false
end


local userIdentityTokens = {
  {
    policyId = "anonymous",
    tokenType = ua.UserTokenType.Anonymous
  }
}


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

  userIdentityTokens = userIdentityTokens,
  authenticate = authenticate,
}

local server = ua.newServer(config)
server:initialize()
server:run()

server:shutdown()
