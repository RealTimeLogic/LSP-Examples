local ua = require("opcua.api")
local hostname = "localhost"
local applicationUri = "urn:localhost:RealTimeLogic"

print("generating private key")
local basic128rsa15Cert, basic128rsa15Key = ua.Init.genServerCertificate(hostname, applicationUri)

print(basic128rsa15Key)
print(basic128rsa15Cert)
