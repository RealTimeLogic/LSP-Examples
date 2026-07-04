local hostname = 'localhost'
local applicationName = 'RealTimeLogic OPCUA Client'
local applicationUri = 'urn:realtimelogic.com:opcua:client'
local outputDirectory = '.'

local initClient = require('opcua.init').initializeClient
initClient(hostname, applicationName, applicationUri, outputDirectory)
