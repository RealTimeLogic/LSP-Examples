local ua = require("opcua.api")

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

local err, resp

local clientConfig = {
  applicationName = 'RealTimeLogic example',
  applicationUri = "urn:localhost:RealTimeLogic",

  io = _G.io,
  certificate = clientCertificate,
  key =         clientKey,

  securePolicies = {
    { -- #1 Required to discover secure policies
      securityPolicyUri = ua.SecurityPolicy.None
    },
    { -- #2
      securityPolicyUri = ua.SecurityPolicy.Basic256Sha256,
      securityMode = ua.MessageSecurityMode.SignAndEncrypt,
    }
  },
}

local c = ua.newClient(clientConfig)

-- Connecto to server
err = c:connect("opc.tcp://localhost:4841")
if err ~= nil then error(err) end

-- Open channel with secure policy None. In this mode server
-- should allow to call endpoint services
resp, err = c:openSecureChannel(3600000,
  ua.SecurityPolicy.None, ua.MessageSecurityMode.None)

-- Select endpoints
resp, err = c:getEndpoints()
if err ~= nil then error(err) end

-- close secure channel (TCP connection is still alive)
err = c:closeSecureChannel()

-- Search secure policy
local basic256Sha256
for _, endpoint in ipairs(resp.Endpoints) do
  if endpoint.SecurityPolicyUri == ua.SecurityPolicy.Basic256Sha256 then
    basic256Sha256 = endpoint
    break
  end
end

if not basic256Sha256 then
  error("Cannot find Basic256Sha256 policy on the server")
end

-- Open secure channel. Specify secure policy and server certificate
resp, err = c:openSecureChannel(
  3600000,
  ua.SecurityPolicy.Aes128_Sha256_RsaOaep, ua.MessageSecurityMode.SignAndEncrypt,
  basic256Sha256.ServerCertificate)




