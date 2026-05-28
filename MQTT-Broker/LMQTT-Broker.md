# LMQTT Broker

**LMQTT Broker** - a compact Lua MQTT broker for Barracuda App Server.

LMQTT Broker is a small MQTT 3.1.1 / MQTT 5.0 broker implemented in Lua for Barracuda App Server runtimes. It can run in [Mako Server](https://makoserver.net/), [Xedge](https://realtimelogic.com/products/xedge/), and other Barracuda App Server derivatives that provide [BAS cosockets](https://realtimelogic.com/ba/doc/en/lua/SockLib.html#cosocket) and SharkSSL.

The broker is designed for embedded systems and application-local message routing. It supports QoS 0 publish/subscribe routing, optional TLS, optional authentication, publish filtering, and optional wildcard-subscription blocking.
For Lua code that should publish and subscribe without loopback TCP, see the [In-Process Client API](#in-process-client-api).

## Module

File:

```text
www/.lua/mqttbroker.lua
```

Load with:

```lua
local mqttbroker=require("mqttbroker")
```

Return value:

```lua
{
   create=create
}
```

## Create

```lua
local broker,err=mqttbroker.create([port [, options]])
local broker,err=mqttbroker.create([options])
```

Creates one or more MQTT listeners and returns a broker object.

Default ports:

- No TLS: `1883`
- TLS with `shark`: `8883`
- Explicit `port` always wins

Examples:

```lua
local broker=require("mqttbroker").create()
```

```lua
local broker=require("mqttbroker").create(1883)
```

```lua
local broker=require("mqttbroker").create({
   shark=shark
})
```

```lua
local broker=require("mqttbroker").create({
   shark=shark,
   plain=true
})
```

The last example opens TLS MQTT on `8883` and plain MQTT on `1883`, sharing the same broker state.

## Options

```lua
{
   address=nil,
   port=nil,
   plain=false,
   plainPort=1883,
   shark=nil,
   maxPacketSize=262144,
   auth=nil,
   onpublish=nil,
   onerror=nil,
   allowWildcards=true
}
```

`address`
: Optional bind address. Mapped to BAS `ba.socket.bind` option `intf`.

`port`
: Main listener port. Defaults to `1883`, or `8883` when `shark` is set.

`plain`
: When `shark` is set, `plain=true` also opens a non-TLS listener.

`plainPort`
: Plain listener port used with `plain=true`. Defaults to `1883`.

`shark`
: SharkSSL server object for TLS MQTT.

`maxPacketSize`
: Maximum accepted MQTT Remaining Length. Larger packets are rejected.

`auth`
: Optional authentication callback.

`onpublish`
: Optional publish policy callback.

`onerror`
: Optional error callback.

`allowWildcards`
: Set to `false` to reject any subscription filter containing `+` or `#`. See the [MQTT Security Tutorial](https://realtimelogic.com/articles/How-Hackers-Can-Easily-Penetrate-Your-MQTT-Solution) for details.

## Broker Object

```lua
broker:close()
broker:shutdown()
broker:status()
broker:createClient(onstatus,onpub,opt)
```

`broker:close()`
: Stops listeners and the keepalive timer. Connected clients are not explicitly closed.

`broker:shutdown()`
: Stops listeners, cancels the timer, and closes all connected clients.

`broker:status()`
: Returns a table similar to:

```lua
{
   running=true,
   clients=2,
   port=8883,
   ports={8883,1883},
   listeners={
      {port=8883,tls=true,address=nil},
      {port=1883,tls=false,address=nil}
   },
   maxPacketSize=262144
}
```

`broker:createClient(onstatus,onpub,opt)`
: Creates an in-process client connected directly to the broker. See [In-Process Client API](#in-process-client-api).

## Authentication Callback

```lua
auth=function(client,username,password)
   return true
end
```

Return `true` to accept the connection. Return `false` or `nil` to reject it.

Example:

```lua
auth=function(client,username,password)
   if username == nil and password == nil then return true end
   return username == "mqttuser" and password == "mqttpass"
end
```

For MQTT 3.1.1, rejected clients receive a CONNACK failure code when possible. For MQTT 5, rejected clients receive a failure reason code.

## Publish Policy Callback

```lua
onpublish=function(client,topic,payload,retain)
   return true
end
```

Called after an inbound QoS 0 PUBLISH is decoded and before it is routed.

Arguments:

- `client`: publishing client table
- `topic`: MQTT topic name
- `payload`: Lua string containing the payload bytes
- `retain`: boolean indicating whether the inbound PUBLISH retain flag was set

Return behavior:

- `false`: drop/reject the message
- `true` or `nil`: route the message normally
- error: call `onerror(client, "onpublish", err)` and drop the message

Example:

```lua
onpublish=function(client,topic,payload,retain)
   if topic:sub(1,8) == "blocked/" then return false end
end
```

QoS 0 has no PUBACK, so rejected messages are silently dropped from the MQTT client's perspective.

## Error Callback

```lua
onerror=function(client,etype,status)
   trace("mqttbroker onerror",etype,status,client and client.clientId or "")
end
```

Called for broker-observed errors such as protocol errors, authorization failures, write failures, keepalive timeouts, and callback errors.

## Wildcard Policy

By default, MQTT wildcards are allowed:

```lua
allowWildcards=true
```

Disable wildcard subscriptions:

```lua
allowWildcards=false
```

When disabled, filters containing `+` or `#` are rejected. Exact subscriptions still work.

MQTT 3.1.1 clients receive SUBACK return code `0x80`. MQTT 5 clients receive reason code `0xA2` Wildcard Subscriptions not supported.

## TLS Setup Example

This example mirrors the current `.preload` style and uses Mako Server's internal certificate.

Important: Mako's internal certificate is self-signed. Test clients must either trust it explicitly or disable certificate verification. The included Python test script uses `--tls` with certificate verification disabled.

```lua
mako.createloader(io)

-- Create a SharkSSL certificate from Mako's internal ZIP file.
local iovm = ba.openio("vm")
local certf=".certificate/MakoServer.%s"
local cert,err=ba.create.sharkcert(
   iovm,
   string.format(certf,"pem"),
   string.format(certf,"key"),
   "sharkssl")
if not cert then error"Certificate not found" end

-- Create a SharkSSL server object.
local shark=ba.create.sharkssl(nil,{server=true})
shark:addcert(cert)

local op={
   shark=shark,
   plain=true,

   auth=function(client,username,password)
      if username == nil and password == nil then return true end
      return username == "mqttuser" and password == "mqttpass"
   end,

   onpublish=function(client,topic,payload,retain)
      if topic:sub(1,8) == "blocked/" then return false end
   end,

   onerror=function(client,etype,status)
      trace("mqttbroker onerror",etype,status,client and client.clientId or "")
   end
}

local mqttBroker,err=require("mqttbroker").create(op)
if not mqttBroker then error(err or "cannot create MQTT broker") end

function onunload()
   if mqttBroker then mqttBroker:shutdown() end
end
```

With this configuration:

- TLS MQTT listens on `8883`
- Plain MQTT listens on `1883`
- Both listeners share the same clients and subscriptions

## No-Wildcard Broker Example

```lua
local exactOnlyBroker,err=require("mqttbroker").create(1884,{
   allowWildcards=false,
   auth=op.auth,
   onpublish=op.onpublish,
   onerror=op.onerror
})
if not exactOnlyBroker then error(err or "cannot create no-wildcard MQTT broker") end
```

## Supported MQTT Features

Supported:

- MQTT 3.1.1 and MQTT 5.0 clients
- CONNECT / CONNACK
- QoS 0 PUBLISH routing
- SUBSCRIBE / SUBACK
- UNSUBSCRIBE / UNSUBACK
- PINGREQ / PINGRESP
- DISCONNECT
- Clean sessions only
- Topic filters with `+` and `#`, unless disabled
- Optional username/password authentication
- Optional TLS through SharkSSL
- In-process broker client API via `broker:createClient(...)`

Not implemented:

- QoS 1 or QoS 2 delivery
- Retained message storage
- Persistent sessions
- Will message delivery
- Shared subscriptions
- Topic aliases
- MQTT 5 flow control
- Will message delivery for in-process clients
- QoS 1 or QoS 2 for in-process clients
- Per-network-client outbound queues

## In-Process Client API

```lua
local mqtt=broker:createClient(onstatus,onpub,opt)
```

The API intentionally resembles the public [MQTT Client API](https://realtimelogic.com/ba/doc/en/lua/MQTT.html) where it makes sense:

```lua
mqtt:publish(topic,msg,opt,prop)
mqtt:subscribe(topic,onsuback,opt,prop)
mqtt:unsubscribe(topic,onunsubscribe,prop)
mqtt:disconnect(reason)
mqtt:close()
mqtt:status()
```

`setwill()` is not implemented. Will messages are outside the broker's minimal feature scope.

The in-process client is a broker-local client:

- it does not open a socket
- it does not encode MQTT packets
- it can publish to network clients
- it can subscribe to messages from network clients
- it can exchange messages with other in-process clients

`onstatus`
: Optional status callback. It is called with a connect status when the local client is created and with a disconnect status when it disconnects.

`onpub`
: Default publish callback for messages received by the local client.

`opt.clientidentifier`
: Optional local client identifier. A generated `local-N` id is used when omitted.

`opt.recbta`
: Controls payload type passed to `onpub`. Defaults to `true`, which passes a `ba.bytearray`. Set `recbta=false` to receive payloads as Lua strings.

Example:

```lua
local localClient=broker:createClient(
   function(etype,status,info)
      trace("local status",etype,status)
   end,
   function(topic,payload)
      trace("local received",topic,payload)
   end,
   {
      clientidentifier="local-app",
      recbta=false
   })

localClient:subscribe("device/+/state")
localClient:publish("app/event","started")
```

Per-subscription receive callback:

```lua
localClient:subscribe("device/+/state",nil,{
   onpub=function(topic,payload)
      trace("subscription callback",topic,payload)
   end
})
```

Local publishes are queued and drained by a broker-owned cosocket. This makes `mqtt:publish()` safe to call from non-cosocket application code. The queue is only for in-process client publishes; regular network clients still use direct socket routing.

Broker listener policies are not imposed on this internal API. In particular, local-client publishes do not call the broker `onpublish` policy callback, and local-client subscriptions are not rejected by `allowWildcards=false`. Application code using `createClient()` is already trusted in-process code.

`mqtt:status()` returns:

```lua
queued, connected, disconnected = mqtt:status()
```

## Test Script

The general broker test script uses `paho-mqtt`:

```powershell
python design/test_mqtt_broker.py --tls --port 8883 --auth --negative --dual --onpublish
```

This test mode covers:

- MQTT 3.1.1 and MQTT 5 delivery
- TLS connections accepting any server certificate
- `+` and `#` wildcard routing
- `$` topic wildcard exclusion
- authentication accept/reject behavior
- publish policy allow/reject behavior
- cross-listener TLS-to-plain routing
- QoS 1 rejection
- invalid wildcard rejection
- MQTT 5 Topic Alias rejection

The `--all` flag also runs `allowWildcards=false` tests, which require a separate broker listening on port `1884`, such as the no-wildcard example above.

The in-process broker client API is tested with:

```powershell
python test_broker_local_client.py --tls --port 8883
```

This test publishes from a Python MQTT client to the `.preload` local broker client and verifies that the local client responds through `broker:createClient(...)`.
