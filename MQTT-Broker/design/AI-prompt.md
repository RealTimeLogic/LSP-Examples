# Prompt for Generating a Minimal MQTT Broker

Act as an expert Lua systems programmer, an expert in MQTT 3.1.1 and MQTT 5.0, and an expert in the Barracuda App Server / Real Time Logic Lua runtime.

Generate a single Lua module named `mqttbroker.lua` implementing a compact MQTT broker for Barracuda App Server. The broker must accept MQTT 3.1.1 and MQTT 5.0 clients on each configured listener and route QoS 0 publications between subscribed clients. The final implementation may open either one listener or two listeners that share one broker state: one plain MQTT listener and one TLS listener.

Use the same packet assembly and packet decoding mechanisms used by the Real Time Logic MQTT client stack, especially the two-pass `ba.bytearray` encoding pattern. The generated broker must be suitable for embedded systems and must avoid unnecessary MQTT 5 features.

Use these files as the primary references:

- **BAS documentation bundle (`basapi.md`)**  
  basapi.md
- ** MQTT 5.0 client, but do not use the flow control buffers in the broker as it is not required **  
  mqttc.lua



## Feature Scope

Implement:

1. MQTT 3.1.1 CONNECT, CONNACK, PUBLISH, SUBSCRIBE, SUBACK, UNSUBSCRIBE, UNSUBACK, PINGREQ, PINGRESP, DISCONNECT.
2. MQTT 5.0 CONNECT, CONNACK, PUBLISH, SUBSCRIBE, SUBACK, UNSUBSCRIBE, UNSUBACK, PINGREQ, PINGRESP, DISCONNECT.
3. QoS 0 only.
4. Clean sessions only. Do not persist sessions after disconnect.
5. Topic filters with MQTT wildcards `+` and `#`.
6. Optional username/password authentication callback.
7. Optional publish policy callback that can drop inbound QoS 0 publications before routing.
8. Optional policy to reject wildcard subscriptions.
9. Optional TLS listener via BAS SharkSSL, including dual plain/TLS listener mode.
10. Broker-integrated local client API for Lua code that publishes and subscribes through the broker without a loopback MQTT connection.

Do not implement:

1. QoS 1 or QoS 2 delivery state machines.
2. MQTT 5 User Properties, except to skip well-formed incoming properties when needed.
3. Topic Aliases.
4. MQTT 5 flow control / Receive Maximum enforcement.
5. Will Delay.
6. Shared subscriptions.
7. Subscription identifiers.
8. Server-side session expiry persistence.
9. Message expiry storage.
10. Retained message storage.
11. Will support for broker-local clients.
12. Per-network-client outbound queues or sender cosockets.

MQTT 5 support must be compatibility-focused. Do not add MQTT 5 features unless they are required to interoperate with MQTT 5 clients.

## Module Contract

Return a table with:

```lua
return {
   create=create
}
```

`create(port [, options])` or `create(options)` starts one or more broker listeners and returns a broker object.

The broker object must provide:

```lua
broker:close()
broker:shutdown()
broker:status()
broker:createClient(onstatus,onpub,opt)
```

Suggested options:

```lua
{
   address=nil,              -- optional bind address if BAS bind API supports it
   port=nil,                 -- defaults to 1883, or 8883 when shark is set
   plain=false,              -- when shark is set, also open a plain listener
   plainPort=1883,           -- plain listener port used with plain=true
   backlog=nil,              -- optional listener backlog if BAS bind API supports it
   shark=nil,                -- optional server TLS/SharkSSL config passed to ba.socket.bind
   timeout=5000,             -- optional socket timeout
   maxPacketSize=262144,     -- reject larger MQTT Remaining Length values
   allowWildcards=true,      -- false rejects SUBSCRIBE filters containing + or #
   auth=function(client, username, password) return true end,
   onpublish=function(client, topic, payload, retain) return true end,
   onerror=function(client, etype, status) end
}
```

The generated code may omit callbacks that are nil. The supported callbacks are `auth`, `onpublish`, and `onerror`. It must validate user-facing arguments with clear errors.

Default listener behavior:

1. `create()` opens plain MQTT on 1883.
2. `create({shark=shark})` opens MQTT over TLS on 8883.
3. `create({shark=shark, plain=true})` opens TLS on 8883 and plain MQTT on 1883, sharing the same broker state.
4. Explicit ports override defaults.

## Broker-Integrated Local Client API

Implement a broker-local client API that resembles the public `mqttc.lua` API where that API makes sense inside the broker:

```lua
local client=broker:createClient(onstatus,onpub,{
   clientidentifier="local-service",
   recbta=false
})

client:publish(topic,payload,opt,prop)
client:subscribe(topic,onsuback,opt,prop)
client:unsubscribe(topic,onunsubscribe,prop)
client:disconnect(reason)
client:close()
client:status()
```

Do not include `setwill()`.

Local client behavior:

1. `broker:createClient(onstatus,onpub,opt)` creates a client record in the same broker client table used by network clients.
2. `opt.clientidentifier` sets the client id. If omitted, generate one.
3. `opt.recbta` controls payload delivery to `onpub`; default `true` delivers a `ba.bytearray`, and `false` delivers a Lua string.
4. `onstatus` is called for local connect and disconnect status changes.
5. `onpub(topic,payload,properties,cpt)` receives matching routed publications. A per-subscription `opt.onpub` passed to `subscribe` may override the client's default `onpub`.
6. `subscribe` validates MQTT topic-filter syntax and stores the filter in `client.subscriptions`.
7. `publish` validates MQTT topic-name syntax, queues the publication in a broker-level local publish queue, and returns without requiring the caller to be in a BAS cosocket.
8. A broker-owned non-connected cosocket drains the local publish queue and calls the same `routePublish` function used by network-client publishes.
9. Local publishes and local subscriptions do not apply the broker's network-facing `onpublish` callback or `allowWildcards` policy. This API is trusted in-process integration code, not a simulated remote client.
10. Local clients do not implement QoS 1/2, retained messages, will messages, MQTT 5 user-property forwarding, or session persistence.

## BAS Listener and Cosocket Model

Use BAS sockets and cosockets.

The broker must use this model:

1. Create the listening socket with `ba.socket.bind(port, op)` .
2. Start the accept loop using `listener:event(acceptLoop, "r", broker)`.
3. In the accept loop, repeatedly call `listener:accept()` and create one connected client cosocket per accepted socket using `clientSock:event(clientRun, "s", broker)` or another BAS-supported connected-cosocket pattern.
4. The connected client cosocket owns reads from that client socket. It decodes MQTT packets and handles the client lifecycle.
5. Since the broker only receives and sends messages from within the cosocket, no special socket flow control is required. The cosocket will auto yield when full.
6. Broker-local publishes use one broker-owned non-connected cosocket only to drain the local publish queue. This queue is not a per-network-client outbound queue.

## Per-Client State

Each connected client must maintain:

```lua
client.sock
client.version       -- 4 for MQTT 3.1.1, 5 for MQTT 5.0
client.clientId
client.connected
client.keepalive
client.lastPacketTime
client.subscriptions -- topic filter set/table
client.recOverflowData
```

Broker-local clients additionally maintain:

```lua
client.localClient   -- true
client.onstatus
client.onpub
client.recbta
```

Do not implement per-network-client MQTT packet queues. Do not create `sndCosock`, `clientSender`, or per-client outbound queue counters.

All network MQTT receive and send operations happen while executing inside a BAS cosocket. When routing a network-client-originated PUBLISH, the same cosocket may encode an outbound QoS 0 PUBLISH packet and call `subscriber.sock:write(bta)` for each matching socket subscriber. BAS will automatically yield the cosocket when TCP output is full.

If a write to a subscriber fails, close and cleanup that subscriber. Do not retry QoS 0 messages.

Do not build outbound packets by concatenating many strings. Build each packet as one `ba.bytearray`.

## Packet Constants

Define MQTT control packet constants as high-nibble values:

```lua
local MQTT_CONNECT    =0x01<<4
local MQTT_CONNACK    =0x02<<4
local MQTT_PUBLISH    =0x03<<4
local MQTT_PUBACK     =0x04<<4
local MQTT_PUBREC     =0x05<<4
local MQTT_PUBREL     =0x06<<4
local MQTT_PUBCOMP    =0x07<<4
local MQTT_SUBSCRIBE  =0x08<<4
local MQTT_SUBACK     =0x09<<4
local MQTT_UNSUBSCRIBE=0x0a<<4
local MQTT_UNSUBACK   =0x0b<<4
local MQTT_PINGREQ    =0x0c<<4
local MQTT_PINGRESP   =0x0d<<4
local MQTT_DISCONNECT =0x0e<<4
```

Only PUBLISH QoS 0 is supported. Packet handlers for PUBACK, PUBREC, PUBREL, and PUBCOMP may report protocol errors or close the client.

## Bytearray Requirements

Use these local aliases:

```lua
local btaCreate,btaCopy,btah2n,btan2h,btaSize,btaSetsize,bta2string=
   ba.bytearray.create,ba.bytearray.copy,ba.bytearray.h2n,ba.bytearray.n2h,
   ba.bytearray.size,ba.bytearray.setsize,ba.bytearray.tostring
```

Assemble MQTT binary data with `ba.bytearray`. Use Lua string concatenation only for temporary socket fragment collection before the packet payload bytearray is allocated.

Use two-pass encoding:

1. Encoding helpers accept `bta == nil` for sizing mode and return the next index without writing.
2. The same helpers write bytes when `bta` is a bytearray.
3. Use 1-based indexes.
4. Use `btah2n` and `btan2h` for big-endian 2-byte and 4-byte integers.
5. MQTT strings and binary values use 2-byte length prefixes.
6. A Lua string or bytearray payload may be assigned with `bta[ix]=payload`.
7. Use `btaSetsize(bta, payloadStartIx)` only if the implementation needs a payload-only bytearray view. For pure broker routing, it may route using the original bytearray and payload start index without exposing callbacks.

Implement:

```lua
encVBInt(bta, ix, len)
encByte(bta, ix, byte)
enc2BInt(bta, ix, number)
enc4BInt(bta, ix, number)
encString(bta, ix, str)
encBinData = encString
decVBInt(bta, ix)
decByte(bta, ix)
dec2BInt(bta, ix)
dec4BInt(bta, ix)
decString(bta, ix)
decBinData = decString
```

Create packet buffers with:

```lua
local function btaCreate2(packetLen)
   return btaCreate(1+encVBInt(nil,0,packetLen)+packetLen)
end
```

## Packet Receive Function

Implement `mqttRec(client)`:

1. Start with any `client.recOverflowData`, then clear it.
2. Read enough socket data to decode fixed header byte and MQTT Remaining Length variable byte integer.
3. Reject malformed Remaining Length values that use more than 4 bytes or exceed `broker.opt.maxPacketSize`.
4. Preserve full fixed header byte as `cpt`.
5. Allocate `btaCreate(len)` for the remaining payload when `len > 0`.
6. Copy already-read payload bytes into the bytearray with `btaCopy`.
7. Continue reading socket fragments until exactly `len` payload bytes are available.
8. Store excess bytes from a fragment in `client.recOverflowData`.
9. Return `cpt,bta` or `nil,err`.

Dispatch handlers by `cpt & 0xF0`, while passing original `cpt` to PUBLISH to inspect flags.

## Minimal MQTT 5 Properties

MQTT 5 requires property length fields in many packets even when there are no properties. Implement enough property parsing to skip valid incoming properties and enough property encoding to send minimum valid responses.

For MQTT 5 incoming packets, implement a generic property skipper:

```lua
skipProps(bta, ix) -> propT, nextIx or nil, "protocolerror"
```

It must:

1. Decode the MQTT property length as Variable Byte Integer.
2. Walk exactly that many bytes.
3. Understand the value type for known property identifiers so it can skip correctly.
4. Store only properties the broker needs for validation: `sessionexpiryinterval`, `maximumPacketSize`, `requestProblemInformation`, `authenticationMethod`, `authenticationData`.
5. Skip MQTT 5 User Properties id 38 by reading key string and value string, but do not store or forward them.
6. Reject unknown property ids as protocol errors.
7. Reject Topic Alias id 35 because this broker does not support topic aliases.

Minimum outgoing MQTT 5 properties:

1. CONNACK must include a property length field.
2. Prefer encoding CONNACK property `maximumqos` id 36 with value 0 so MQTT 5 clients know QoS 1 and QoS 2 are unavailable.
3. Do not encode Receive Maximum, Topic Alias Maximum, User Properties, or Will Delay.
4. SUBACK and UNSUBACK must include a property length field, usually zero.
5. DISCONNECT must include reason code and property length when sending MQTT 5 DISCONNECT.
6. PUBLISH from broker to MQTT 5 clients must include a property length field, usually zero, before the payload.

## CONNECT Handling

The first packet from a client must be CONNECT. Decode:

1. Protocol name string.
2. Protocol level: 4 means MQTT 3.1.1; 5 means MQTT 5.0.
3. Connect flags.
4. Keepalive.
5. For MQTT 5 only, CONNECT properties using `skipProps`.
6. Client identifier.
7. Optional will topic and payload if will flag is set.
8. Optional username and password.

Validation:

1. Protocol name must be `MQTT`.
2. Protocol level must be 4 or 5.
3. Reserved connect flag bit 0 must be zero.
4. QoS bits in Will flags must not be 3.
5. If Will QoS is not 0, reject the connection because only QoS 0 is supported.
6. Accept Will flag only for QoS 0 and immediate will behavior if implemented. A minimal broker may reject all Will messages with CONNACK failure to avoid implementing will storage and dispatch.
7. Empty client identifiers may be accepted by assigning a generated id.
8. Reject malformed CONNECT packets with CONNACK failure when possible, otherwise close the socket.
9. If the auth callback rejects username/password, send CONNACK not authorized and close.

CONNACK:

For MQTT 3.1.1:

```text
fixed header: CONNACK, Remaining Length 2
variable header: session present byte 0, return code
```

Use return code 0 for success, 4 for bad username/password, 5 for not authorized, and close on other protocol errors.

For MQTT 5.0:

```text
fixed header: CONNACK
variable header: connect acknowledge flags 0, reason code, properties
```

Use reason code 0 for success. On failure, use MQTT 5 reason codes such as 0x84 Unsupported Protocol Version, 0x85 Client Identifier not valid, 0x86 Bad User Name or Password, 0x87 Not authorized, 0x81 Malformed Packet, or 0x82 Protocol Error.

Set `client.connected=true` only after successful CONNACK is written.

## PUBLISH Handling

Inbound client PUBLISH:

1. Fixed header flags provide DUP, QoS, and RETAIN.
2. Reject QoS 1 or QoS 2 because this broker supports QoS 0 only. For MQTT 5 clients, preferably send DISCONNECT reason 0x9B QoS not supported. For MQTT 3.1.1 clients, close the socket.
3. Decode topic name. Topic name must not be empty.
4. MQTT 5 PUBLISH has property length and properties after topic name; skip them with `skipProps`.
5. Reject Topic Alias properties.
6. The remaining bytes are payload.
7. If `onpublish` is set, call `onpublish(client, topic, payload, retain)` before routing.
8. If `onpublish` returns `false`, drop the message. Returning `true` or `nil` allows routing. If it errors, call `onerror(client, "onpublish", err)` and drop the message.
9. Route the publication to all connected network clients and broker-local clients with matching subscriptions.
10. Do not echo suppression by default; if a publishing client is subscribed to the topic, it should receive its own publication.
11. Ignore the RETAIN flag or reject retained PUBLISH packets consistently; do not store retained messages and do not send retained publications to new subscribers.

Outbound broker PUBLISH to network clients:

1. Always send QoS 0.
2. Fixed header is `MQTT_PUBLISH`. Do not set the RETAIN flag.
3. Variable header is topic string.
4. For MQTT 5 clients, add property length 0 before payload.
5. Encode with the two-pass bytearray method.
6. Write directly with `subscriber.sock:write(bta)` from within the broker cosocket that is routing the message.

Outbound delivery to local clients:

1. If a matching subscriber has `localClient=true`, do not encode an MQTT packet.
2. Deliver directly to the local callback, using the per-subscription callback when present or the client's default `onpub`.
3. Convert payload to a Lua string only when the local client has `recbta=false`.
4. If the callback raises an error, report it through `onerror(client, "onpub", err)` when available and keep the broker running.

## SUBSCRIBE Handling

SUBSCRIBE fixed header must have flags `0x02`; otherwise protocol error.

Decode:

1. Packet identifier.
2. For MQTT 5, property length and properties, skipped with `skipProps`.
3. One or more topic filters.
4. For each topic filter, decode subscription options byte.

Validation:

1. Packet identifier must be nonzero.
2. Topic filter must be syntactically valid.
3. QoS request may be 0, 1, or 2, but the broker grants only QoS 0.
4. Reject malformed options, invalid retain handling, and invalid wildcard placement.
5. Shared subscriptions beginning with `$share/` are not supported; reject those filters.
6. When `allowWildcards=false`, reject any filter containing `+` or `#`. MQTT 3.1.1 returns SUBACK `0x80`; MQTT 5 returns reason `0xA2`.

Store each accepted topic filter in `client.subscriptions`.

SUBACK:

For MQTT 3.1.1:

```text
packet id, then one return code per requested filter
```

Return 0 for each accepted filter and 0x80 for each rejected filter.

For MQTT 5.0:

```text
packet id, property length 0, then one reason code per requested filter
```

Return 0 for granted QoS 0. Return 0x8F Topic Filter invalid or 0x9E Shared Subscriptions not supported where appropriate.

Do not send retained messages because retained message storage is out of scope.

## UNSUBSCRIBE Handling

UNSUBSCRIBE fixed header must have flags `0x02`; otherwise protocol error.

Decode:

1. Packet identifier.
2. For MQTT 5, property length and properties, skipped with `skipProps`.
3. One or more topic filters.

Remove each topic filter from `client.subscriptions`.

UNSUBACK:

For MQTT 3.1.1:

```text
packet id only
```

For MQTT 5.0:

```text
packet id, property length 0, then one reason code per topic filter
```

Use reason code 0 for success and 0x11 No subscription existed if helpful. A minimal implementation may return 0 for every well-formed topic filter.

## PINGREQ and DISCONNECT

PINGREQ must have Remaining Length 0. Respond with PINGRESP Remaining Length 0.

DISCONNECT:

1. MQTT 3.1.1 DISCONNECT must have Remaining Length 0.
2. MQTT 5 DISCONNECT may include reason code and properties. Decode enough to consume it cleanly.
3. Close the client normally and remove subscriptions.

Implement keepalive:

1. Track `client.lastPacketTime` each time a packet is received.
2. If keepalive is nonzero, close the client after no packet is received for more than 1.5 times keepalive.
3. Use a broker timer to periodically scan connected clients, or set per-client timers. Prefer one broker timer for compactness.

## Topic Matching

Implement MQTT topic filter validation and matching:

1. `+` matches exactly one topic level.
2. `#` matches zero or more levels and is valid only as the final level and either alone or following a slash.
3. Wildcards are allowed only in topic filters, not topic names in PUBLISH.
4. Topic names and filters are UTF-8 strings at the MQTT layer; the implementation may treat them as Lua byte strings but must preserve bytes.
5. Do not match topics beginning with `$` against filters beginning with `+` or `#`, per MQTT convention.

Maintain per-client subscriptions only. For small embedded systems, scanning connected clients and their filters on each publish is acceptable and preferred over a subscription index.

## Broker State

Maintain:

```lua
broker.listener
broker.listeners     -- list of listener records for single or dual listener mode
broker.ports         -- listener port list for status()
broker.opt
broker.clients       -- set/table of connected clients
broker.timer
broker.nextClientNo
broker.localQ
broker.localQHead
broker.localQTail
broker.localQElems
broker.localCosock
```

Client ids must be unique among connected network clients and broker-local clients. If a new CONNECT or local client uses an existing client id, close the previous client and replace it, matching normal MQTT broker behavior.

On network client cleanup:

1. Remove the client from `broker.clients`.
2. Remove all subscriptions.
3. Close the socket.

On local client cleanup:

1. Remove the client from `broker.clients`.
2. Remove all subscriptions.
3. Call `onstatus("disconnect", reason)` when provided.

## Error Handling

For protocol errors after a successful MQTT 5 CONNECT, send MQTT 5 DISCONNECT with the best reason code and property length 0 before closing when practical.

For MQTT 3.1.1 protocol errors after CONNECT, close the socket.

Before CONNECT or when protocol version is unknown, close the socket unless a CONNACK failure can be encoded safely.

All socket read/write failures should cleanup the client without crashing the broker.

## Coding Style

Use local aliases for hot functions such as `string.format`, `string.byte`, `string.sub`, `table.insert`, and `table.remove` where useful.

Use small local helper functions. Avoid class frameworks.

Use Lua bitwise operators (`<<`, `>>`, `&`, `|`) directly.

Keep the broker compact and readable. Prefer simple tables over complex abstractions.

Include comments only where they explain protocol or cosocket behavior that is easy to get wrong.

The final output must be a complete `mqttbroker.lua` source file implementing the behavior above.

In `www\.preload`, add code for loading the module using `require`, create a broker instance, configure TLS with Mako's self-signed internal certificate when SharkSSL is available, enable both TLS and plain listeners when requested, and add a small broker-local client fixture that subscribes to `lmqtt/local/request` and publishes replies on `lmqtt/local/response` so the integrated API can be tested from an external Python MQTT client.
