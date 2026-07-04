local ua = require("opcua.api")

local config = {
  endpoints = {
    {
      endpointUrl = "opc.tcp://localhost:4842"
    }
  },

  securePolicies = {
    {
      securityPolicyUri = ua.SecurityPolicy.None
    }
  }
}

local server = ua.newServer(config)
server:initialize()

local editor = server.model:edit()
local objects = editor:objectsFolder()
local tutorial = objects:addFolder("Tutorial")
tutorial.Attrs.Description = {
  Text = "Folder used by the Mako Server learning examples"
}
editor:save()

trace("Added Tutorial folder under Objects.")

server:run()
server:shutdown()
