-- Load the required modules
local ua = require("opcua.api")

local server = ua.newServer()
server:initialize()

local rootPath = debug.getinfo(1, "S").source
if rootPath:sub(1, 1) == "@" then
  rootPath = rootPath:sub(2)
end
rootPath = rootPath:match("^(.*[/\\])") or ""
rootPath = ba.openio("home"):realpath(rootPath)

server:loadXmlModels({
  rootPath.."euromap83_1_03/Opc.Ua.Di.NodeSet2.xml",
  rootPath.."euromap83_1_03/Opc.Ua.PlasticsRubber.GeneralTypes.NodeSet2.xml"
})

server:run()
server:shutdown()
