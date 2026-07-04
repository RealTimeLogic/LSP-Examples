-- Load the required modules
local ua = require("opcua.api")

local server = ua.newServer()
server:initialize()

local baseUrl = "https://raw.githubusercontent.com/OPCFoundation/UA-Nodeset/refs/heads/latest"
server:loadXmlModels({
  baseUrl.."/DI/Opc.Ua.Di.NodeSet2.xml",
  baseUrl.."/PlasticsRubber/GeneralTypes/1.03/Opc.Ua.PlasticsRubber.GeneralTypes.NodeSet2.xml"
})

server:run()
server:shutdown()
