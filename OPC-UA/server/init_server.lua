local hostname = 'localhost'
local applicationName = 'RealTimeLogic OPCUA Server'
local applicationUri = 'urn:realtimelogic.com:opcua:server'
local outputDirectory = '.'

local initServer = require('opcua.init').initializeServer
initServer(hostname, applicationName, applicationUri, outputDirectory)
