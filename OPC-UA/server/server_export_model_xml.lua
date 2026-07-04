-- Load the required modules
local ua = require("opcua.api")

-- Create and initialize server
local server = ua.newServer()
server:initialize()

-- Load XML models from the OPCUA Foundation github repository
local baseUrl = "https://raw.githubusercontent.com/OPCFoundation/UA-Nodeset/refs/heads/latest"
server:loadXmlModels({
  baseUrl.."/DI/Opc.Ua.Di.NodeSet2.xml",
  baseUrl.."/PlasticsRubber/GeneralTypes/1.03/Opc.Ua.PlasticsRubber.GeneralTypes.NodeSet2.xml"
})

-- Method 1: Export all models to a file
local outputFile = "exported_models.xml"
server:exportXmlModels(outputFile)

print("Exported all models to: " .. outputFile)

-- Method 2: Export model using callback function
-- Print the first 30 and last 30 lines of the exported XML

-- After export, print first and last 30 lines
local function printFirstAndLastLines(xml, numLines)
  numLines = numLines or 30
  local lines = {}
  for line in xml:gmatch("([^\n]*)\n?") do
    table.insert(lines, line)
  end
  local total = #lines
  for i = 1, math.min(numLines, total) do
    trace(lines[i])
  end
  if total > numLines * 2 then
    trace("...")
    trace("...")
    trace("...")
  end
  for i = math.max(1, total - numLines + 1), total do
    trace(lines[i])
  end
end

local modelExportedXml = ""
local function modelExportCallback(str)
  modelExportedXml = modelExportedXml .. str
end

-- Export only specific namespace URIs
local namespaceUris = {
  "http://opcfoundation.org/UA/PlasticsRubber/GeneralTypes/"
}
server:exportXmlModels(modelExportCallback, namespaceUris)

printFirstAndLastLines(modelExportedXml, 30)

-- Start the server (optional - only if you want to run it)
-- server:run()

-- Shutdown the server
server:shutdown()

print("Export examples completed successfully!")
