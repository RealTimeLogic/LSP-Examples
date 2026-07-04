-- require("ldbgmon").connect{client=false}

-- Load the required modules
local ua = require("opcua.api")
local nodeIds = require("tests.node_ids")

local function readFile(path)
  local f = _G.io.open(path, "rb")
  if not f then
    return nil
  end

  local data = f:read("*a")
  f:close()
  return data
end

local function loadCerts()
  local candidates = {
    "certs",
    mako.cfgdir and mako.cfgdir.."/certs" or nil,
  }

  for _, dir in ipairs(candidates) do
    if dir then
      local certificate = readFile(dir.."/client.pem")
      local key = readFile(dir.."/client.key")
      if certificate and key then
        return certificate, key
      end
    end
  end

  error("cannot find client certificate files")
end

local clientCertificate, clientKey = loadCerts()

-- Function for validating user credentials sent by client
-- inside token
local function authenticate(tokenType, token, issuerEnpointUrl)

  if tokenType == "jwt" then
    return true
  elseif tokenType == "azure" then
    return true
  elseif tokenType == "oauth2" then
    return true
  end

  return false
end


local issuedIdentityTokens = {
  {
    policyId = "jwt",
    tokenType = ua.UserTokenType.IssuedToken,
    issuedTokenType = ua.IssuedTokenType.JWT,
    securityPolicyUri = ua.SecurityPolicy.Basic128Rsa15
  },
  {
    policyId = "jwt",
    tokenType = ua.UserTokenType.IssuedToken,
    issuedTokenType = ua.IssuedTokenType.JWT,
    securityPolicyUri = ua.SecurityPolicy.Basic128Rsa15
  },
  {
    policyId = "azure",
    tokenType = ua.UserTokenType.IssuedToken,
    issuedTokenType = ua.IssuedTokenType.Azure,
    securityPolicyUri = ua.SecurityPolicy.Basic128Rsa15
  },
  {
    policyId = "azure",
    tokenType = ua.UserTokenType.IssuedToken,
    issuedTokenType = ua.IssuedTokenType.Azure,
  },
  {
    policyId = "oauth2",
    tokenType = ua.UserTokenType.IssuedToken,
    issuedTokenType = ua.IssuedTokenType.OAuth2,
    securityPolicyUri = ua.SecurityPolicy.Basic128Rsa15
  },
}


local config = {
  endpoints = {
    {
      endpointUrl = "opc.tcp://localhost:4845",
    }
  },

  io = _G.io,
  certificate = clientCertificate,
  key =         clientKey,

  securePolicies = {
    { -- #1
      securityPolicyUri = ua.SecurityPolicy.None,
    },
    { -- #2
      securityPolicyUri = ua.SecurityPolicy.Basic128Rsa15,
      securityMode = ua.MessageSecurityMode.SignAndEncrypt,
    }
  },
  userIdentityTokens = issuedIdentityTokens,
  authenticate = authenticate,
}

local server = ua.newServer(config)
server:initialize()
server:run()

server:shutdown()




