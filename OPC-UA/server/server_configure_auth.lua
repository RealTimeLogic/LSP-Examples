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
local function authenticate(tokenType, token, user)

  if tokenType == "anonymous" then
    return true
  elseif tokenType == "username" then
    return user == "admin" and token == "12345"
  elseif tokenType == "x509" then
    local cert = ba.parsecert(token)
    if cert.subject.commonname ~= "admin" then
      return false
    end

    return true
  end

  return false
end


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

  -- Parameters of user tokens
  userIdentityTokens = {
    {
      policyId = "anonymous",
      tokenType = ua.UserTokenType.Anonymous
    },
    {
      policyId = "username",
      tokenType = ua.UserTokenType.UserName,
      securityPolicyUri = ua.SecurityPolicy.None
    },
    {
      policyId = "username_basic128Rsa15",
      tokenType = ua.UserTokenType.UserName,
      securityPolicyUri = ua.SecurityPolicy.Basic128Rsa15
    },
  },

  authenticate = authenticate,
}

local server = ua.newServer(config)
server:initialize()
server:run()

server:shutdown()




