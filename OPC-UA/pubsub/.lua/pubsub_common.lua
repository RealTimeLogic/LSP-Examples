local M = {}

function M.fail(message)
  trace(message)
  if mako and mako.exit then
    mako.exit(1)
  end
  error(message)
end

function M.loadBroker()
  local ok, mqttbroker = pcall(require, "mqttbroker")
  if ok then
    return mqttbroker
  end

  M.fail(
    "Cannot load MQTT broker module 'mqttbroker'. " ..
    "Use the Mako Server mako.zip Developer Edition, or install the broker " ..
    "from https://github.com/RealTimeLogic/LSP-Examples/tree/master/MQTT-Broker. " ..
    "Original error: " .. tostring(mqttbroker)
  )
end

function M.createBroker(port)
  local brokerModule = M.loadBroker()
  local broker, err = brokerModule.create(port)
  if not broker then
    M.fail("Cannot start local MQTT broker on port " .. tostring(port) .. ": " .. tostring(err))
  end
  return broker
end

function M.connectLocal(uaMqtt, broker, transportProfileUri)
  local mqttClient
  mqttClient = broker:createClient(nil, function(topic, payload, properties, cpt)
    local onpub = uaMqtt.onpub and uaMqtt.onpub[topic]
    if not onpub then
      trace("No OPC UA PubSub callback for local MQTT topic " .. tostring(topic))
      return
    end
    return onpub(topic, payload, properties, cpt)
  end)

  uaMqtt:connect(mqttClient, transportProfileUri)
  return mqttClient
end

function M.waitFor(label, predicate, timeoutMs)
  local elapsed = 0
  local step = 100
  timeoutMs = timeoutMs or 5000

  while elapsed < timeoutMs do
    if predicate() then
      return true
    end
    ba.sleep(step)
    elapsed = elapsed + step
  end

  M.fail("Timed out waiting for " .. label)
end

return M
