# QNX PPS SMQ Bridge

## Overview

Module `pps` extends the [QNX Persistent Publish Subscribe](http://www.qnx.com/developers/docs/7.0.0/#com.qnx.doc.pps.developer/topic/about.html) service so HTML5 and JavaScript applications can subscribe to and publish PPS messages through SMQ.

The bridge uses the [BAS Pipe API](https://realtimelogic.com/ba/doc/?url=auxlua.html#pipe_api) for QNX PPS integration and the [SMQ protocol](https://realtimelogic.com/ba/doc/?url=SMQ.html) for browser-facing messaging. PPS messages are converted automatically between raw PPS, Lua tables on the server, and JavaScript objects in browser apps.

## Files

- `www/.lua/pps.lua` - Lua module that creates the PPS bridge and the companion SMQ broker.

## How to run

This directory provides the reusable bridge module rather than a standalone Mako app. To use it, load the module from your own BAS or QNX application:

```lua
local pps, smq = require"pps".create(op)
```

Then register the PPS topics you want to expose:

```lua
pps:subscribe("/pps/my-service")
```

## How it works

`require"pps".create(op)` creates two objects:

- a PPS bridge object
- an SMQ broker object

When you call `pps:subscribe(topic [, callback])`, the module opens the matching PPS pipe, converts incoming PPS data into a Lua table, remembers the most recent message, and publishes the Lua table on the SMQ side. Messages sent from SMQ in the other direction are converted back into PPS key/value text and written to the PPS topic.

The optional callback is invoked for both directions:

- `egress = true` for PPS-to-SMQ messages
- `egress = false` for SMQ-to-PPS messages

That callback receives the converted Lua table as well as the raw PPS text.

The subscription signature is:

```lua
pps:subscribe(pps_topic [, callback])
```

where `pps_topic` is a PPS path such as `"/pps/my-service"`.

The callback receives three values:

- `egress` - `true` for PPS-to-SMQ traffic and `false` for SMQ-to-PPS traffic
- `tab` - the converted Lua table
- `pps` - the raw PPS message text

### Using PPS with an HTML5 or JavaScript client

A browser SMQ client can subscribe to PPS-backed data like this:

```javascript
smq.subscribe("/pps/my-service", {
   datatype: "json",
   onmsg: function (obj) { /* manage obj */ }
});
```

If the client wants the last known PPS value immediately after startup, it can request it by publishing the PPS topic name to the server's ephemeral topic:

```javascript
smq.publish("/pps/my-service", 1, "last-pps");
smq.subscribe("self", "/pps/my-service", {
   datatype: "json",
   onmsg: function (obj) { /* manage obj */ }
});
```

To publish data back into PPS, use JSON:

```javascript
smq.pubjson({temperature:10}, "/pps/bidirect-tst");
smq.pubjson({temperature:10}, 1, "/pps/bidirect-tst");
```

The first form broadcasts to subscribed SMQ clients as well as to PPS listeners. The second form sends the message only to the PPS service through the bridge.

This distinction is helpful because some applications want browser clients to see each other's PPS-originated changes, while others want the browser to send commands only to the QNX side without echoing them to every other subscriber.

## Notes / Troubleshooting

- Messages are not relayed until each PPS topic has been registered with `pps:subscribe(...)`.
- The module also supports a `last-pps` request flow. A client can publish the PPS topic name to the server's ephemeral topic and then subscribe to `self` with the same subtopic to receive the most recently cached PPS value.
- Browser clients should publish JSON with `smq.pubjson(...)`, because the bridge expects JSON-compatible table data on the SMQ side.
- The same addressing model also applies to other SMQ client stacks, including the Java and C stacks, because the bridge works at the SMQ topic level rather than only in the browser.
- The bridge is especially useful when you want browser tooling around a QNX PPS system without exposing PPS directly to browser code.
