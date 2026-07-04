-- require("ldbgmon").connect{client=false}

-- Load the required modules
local ua = require("opcua.api")
local nodeIds = require("tests.node_ids")

-- Function for validating user credentials sent by client
-- inside token
local function authenticate(tokenType, token)

  if tokenType == "x509" then
    local cert = ba.parsecert(token)
    return cert.subject.commonname == "admin"
  end

  return false
end

-- Parameters of user tokens
local userIdentityTokens = {
  {
    policyId = "x509",
    tokenType = ua.UserTokenType.Certificate,
  },
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
