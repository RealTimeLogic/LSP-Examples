# MQTT Broker Design

## Purpose

`www/.lua/mqttbroker.lua` implements a compact MQTT 3.1.1 / MQTT 5.0 broker for Barracuda App Server. It accepts clients on one or two listeners, supports clean-session QoS 0 messaging, stores subscriptions only in memory, and routes matching publications directly to connected subscriber sockets and broker-local clients.

The implementation deliberately omits QoS 1/2 state, retained storage, per-network-client outbound queues, topic aliases, shared subscriptions, MQTT 5 user-property forwarding, and will handling for broker-local clients. It includes an in-process client API for Lua code that wants to publish and subscribe through the broker without connecting over loopback.

## Top-Level Call Chain

1. `www/.preload` runs when the BAS application loads.
2. `.preload` calls `mako.createloader(io)` so `require()` can load modules from `www/.lua`.
3. `.preload` calls `require("mqttbroker").create(...)`.
4. `create(port, options)` validates options, builds broker state, binds one or two listeners with `ba.socket.bind(port, bindOpt)`, registers each listener with `listener:event(acceptLoop, "r", broker)`, and starts a keepalive scan timer.
5. `acceptLoop(listener, broker)` accepts sockets and registers each accepted socket with `sock:event(clientRun, "s", broker)`.
6. `clientRun(sock, broker)` creates per-client state, reads the first MQTT packet with `mqttRec(client)`, and requires it to be CONNECT.
7. `handleConnect(client, bta, cpt)` decodes CONNECT, validates protocol/version/flags/client id/auth, sends CONNACK, and marks the client connected.
8. `clientRun` then loops on `mqttRec(client)` and dispatches packets by `cpt & 0xF0`.
9. Lua code may also call `broker:createClient(onstatus, onpub, opt)` to create an in-process client that participates in the same subscription and routing table without a socket.

Main dispatch handlers:

- `handlePublish` validates QoS 0, decodes topic/properties/payload, then calls `routePublish`.
- `handlePublish` calls optional `onpublish(client, topic, payload, retain)` before routing. Returning `false` drops the publication; returning `true` or `nil` allows it.
- `routePublish` scans all connected and local clients and their subscription filters, uses `topicMatches`, writes an encoded QoS 0 PUBLISH directly to each matching socket subscriber, and invokes local subscriber callbacks directly.
- `handleSubscribe` decodes filters/options, validates wildcard syntax, optionally rejects wildcard filters when `allowWildcards=false`, stores accepted filters in `client.subscriptions`, and sends SUBACK.
- `handleUnsubscribe` removes filters and sends UNSUBACK.
- `handlePingreq` sends PINGRESP.
- `handleDisconnect` consumes MQTT 3.1.1 or MQTT 5 DISCONNECT and cleans up the client.
- `scanKeepalive` periodically closes clients idle for more than 1.5x their keepalive interval.

Broker-local client call chain:

- `broker:createClient(onstatus, onpub, opt)` creates a client record with `localClient=true`, stores it in `broker.clients`, calls `onstatus("connect")` when provided, and returns a client object.
- `client:subscribe(topic, onsuback, opt, prop)` validates the filter, stores it in the client subscription table, and calls `onsuback(0)` when provided. A per-subscription `opt.onpub` overrides the client's default `onpub`.
- `client:publish(topic, payload, opt, prop)` validates the topic, appends the message to `broker.localQ`, and starts a broker-owned non-connected cosocket when needed.
- `localPublishCosock(sock, broker)` drains the local queue and calls `routePublish` for each queued publication. This keeps local publishes from ordinary non-cosocket Lua code out of the network client receive cosocket.
- `client:unsubscribe(topic, onunsubscribe, prop)` removes subscriptions and calls `onunsubscribe(0)` when provided.
- `client:disconnect(reason)` and `client:close()` remove the local client from the broker and call `onstatus("disconnect", reason)` when provided.

## Packet Encoding And Decoding

The broker follows the Real Time Logic MQTT client style:

- MQTT packets are assembled as `ba.bytearray` objects.
- Encoding helpers support two-pass sizing and writing: `encVBInt`, `encByte`, `enc2BInt`, `enc4BInt`, `encString`, and `encBinData`.
- Decoding helpers mirror the encoders.
- `btaCreate2(packetLen)` allocates the fixed header plus Remaining Length plus packet body.
- `mqttRec(client)` reads the fixed header, decodes Remaining Length, enforces `maxPacketSize`, preserves overflow bytes in `client.recOverflowData`, and returns `cpt,bta`.
- `mqttRec(client)` calculates overflow explicitly by byte count instead of treating `btaCopy`'s return value as overflow. This avoids misclassifying bytes from an exact packet copy as the next MQTT fixed header.

MQTT 5 support is intentionally minimal. `skipProps` parses and skips known property types, stores only properties needed for validation, skips user properties, and rejects Topic Alias.

## State Model

Broker state:

- `listener`
- `listeners`
- `ports`
- `opt`
- `clients`
- `timer`
- `nextClientNo`
- `localQ`
- `localQHead`
- `localQTail`
- `localQElems`
- `localCosock`

Client state:

- `sock`
- `localClient`
- `version`
- `clientId`
- `connected`
- `keepalive`
- `lastPacketTime`
- `subscriptions`
- `recOverflowData`
- `onstatus`
- `onpub`
- `recbta`

There is no per-network-client outbound queue. A routed QoS 0 message from a network client is encoded and written immediately to each matching socket subscriber. A broker-local publish uses one small broker-level queue so non-cosocket Lua code can call `client:publish(...)`; the queue drains through the broker's local publish cosocket and then uses the same `routePublish` path.

## Broker-Local Client API

The broker object exposes a client API shaped like the public `mqttc.lua` client surface, limited to operations that make sense inside the broker:

```lua
local client=broker:createClient(onstatus,onpub,{
   clientidentifier="local-service",
   recbta=false
})

client:subscribe("service/request")
client:publish("service/response","ok")
client:unsubscribe("service/request")
client:disconnect()
client:close()
client:status()
```

`setwill()` is intentionally not provided. Local client QoS 1/2 state, retained storage, and MQTT 5 property forwarding are also out of scope.

Local client payload delivery defaults to `ba.bytearray` to match the network packet style. Set `recbta=false` to receive Lua strings in the local `onpub(topic, payload, properties, cpt)` callback.

The local API is an integration API, not a simulated network client. Per the final design decision, local publishes and local subscriptions do not run the broker's network-facing `onpublish` or `allowWildcards` policy callbacks. They still use MQTT topic and topic-filter syntax validation.

## Listener Options

Default ports:

- `create()` opens plain MQTT on `1883`.
- `create({shark=shark})` opens MQTT over TLS on `8883`.
- An explicit `port` always wins, for example `create(9443,{shark=shark})`.

Dual listener mode:

```lua
local broker=require("mqttbroker").create({
   shark=shark,
   plain=true
})
```

This opens TLS on `8883` and plain MQTT on `1883`, sharing the same broker state and subscription table. Use `plainPort` to override the plain listener port:

```lua
local broker=require("mqttbroker").create({
   shark=shark,
   port=8883,
   plain=true,
   plainPort=1883
})
```

## Policy Options

Publish policy:

```lua
onpublish=function(client,topic,payload,retain)
   if topic:sub(1,8) == "blocked/" then return false end
end
```

`onpublish` runs after a QoS 0 PUBLISH packet is decoded and before routing. Returning `false` rejects the message by dropping it. Returning `true` or `nil` allows normal routing. If the callback raises an error, the broker calls `onerror(client, "onpublish", err)` and drops the message.

Wildcard subscription policy:

```lua
allowWildcards=false
```

When disabled, any SUBSCRIBE filter containing `+` or `#` is rejected. Exact subscriptions still work. MQTT 3.1.1 receives SUBACK `0x80`; MQTT 5 receives reason code `0xA2` Wildcard Subscriptions not supported.

## Prompt/API Clarity And Assumptions

The MQTT feature scope was clear: QoS 0 only, clean sessions only, wildcard subscriptions, optional auth, compatibility-level MQTT 5, and no retained/session/per-network-client queue machinery. The broker-local client API was added later to avoid loopback MQTT connections for in-process Lua code.

The BAS API references were mostly clear for binding, accepting, bytearray usage, timers, and the `socket:event` model. I used the documented listener pattern `ba.socket.bind(...)` followed by `listener:event(acceptLoop, "r", broker)`, and accepted-client registration with `sock:event(clientRun, "s", broker)`.

Assumptions I made:

- `mako.createloader(io)` means `mqttbroker.lua` should live under `www/.lua` and be loaded as `require("mqttbroker")`.
- `options.address` maps to BAS bind option `intf`; `options.shark` maps to bind option `shark`.
- `options.backlog` has no documented BAS bind equivalent in the provided API excerpt, so it is retained in options but not passed to `ba.socket.bind`.
- MQTT 5 authentication-method properties are rejected rather than implementing MQTT enhanced auth.
- Will messages are rejected to avoid storing and dispatching Will state, which the prompt allowed for a minimal broker.
- Retain is ignored on inbound QoS 0 PUBLISH and never set on outbound broker PUBLISH.
- The broker-local API is trusted integration code, so it bypasses network-facing `onpublish` and `allowWildcards` policy checks while still validating topic syntax.

Current test status: `design/test_mqtt_broker.py` exists for paho-mqtt interoperability testing. It passes MQTT 3.1.1 and MQTT 5 delivery tests, `+` and `#` wildcard routing, the MQTT `$` topic wildcard convention, auth accept/reject callback behavior, cross-listener plain/TLS routing, `onpublish` allow/reject behavior, QoS 1 rejection, invalid wildcard SUBACK failure, and MQTT 5 Topic Alias rejection.

The current `.preload` installs broker callbacks:

- `auth` accepts anonymous clients for ordinary smoke tests, accepts `mqttuser` / `mqttpass`, and rejects incorrect supplied credentials.
- `onpublish` rejects topics beginning with `blocked/` and allows all other topics by returning `nil`.
- `onerror` traces broker errors.

It also creates a broker-local client fixture named `brokerApiTest`. The fixture subscribes to `lmqtt/local/request`, records received publications, and uses a timer to publish `reply:<payload>` on `lmqtt/local/response`. The Python local-client test communicates with this fixture over the external broker listener.

The expanded test suite can be run against the TLS listener with:

```powershell
python design\test_mqtt_broker.py --tls --port 8883 --auth --negative --dual --onpublish
```

`--all` also runs the `allowWildcards=false` policy tests, which require a second broker/listener configured for that policy, for example on port `1884`. The simplified `.preload` does not currently start that second broker.

The broker-local client fixture is tested with:

```powershell
python test_broker_local_client.py --tls --port 8883
```

Related documentation:

- `AI-prompt.md`: final prompt and constraints used to produce the broker.
- `LMQTT-Broker.md`: API documentation and usage examples.
- `README.md`: short future-reader index for the implementation and docs.
