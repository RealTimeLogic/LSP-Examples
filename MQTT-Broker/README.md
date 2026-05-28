# LMQTT Broker

## Overview

This example includes **LMQTT Broker**, a compact MQTT 3.1.1 and MQTT 5.0 broker written in Lua for the [Barracuda App Server](https://realtimelogic.com/products/barracuda-application-server/) runtime. It can run with the [Mako Server](https://makoserver.net/), [Xedge](https://realtimelogic.com/products/xedge/), and other BAS derivatives.

## API

See [LMQTT-Broker.md](LMQTT-Broker.md) for the module API, options, callbacks, TLS setup, and feature scope.

## Files (broker module and example files)

- `www/.lua/mqttbroker.lua` - The broker module. **Copy this module to your project**.
- `www/.preload` - Example startup script that creates a SharkSSL TLS listener, enables a plain listener, and installs broker callbacks.
- `design/test_mqtt_broker.py` - Python paho-mqtt test program.

### Installing the module

As mentioned above, copy www/.lua/mqttbroker.lua into your project. When using the Mako Server, you can optionally integrate this module directly into mako.zip by adding it to the .lua directory inside the ZIP archive.

Assuming mako.zip is in the current directory, use the following command from the www directory:

```bash
cd www
zip -r ../mako.zip .lua/mqttbroker.lua
```

## How to run the example:

Start the example with the Mako Server:

```bash
cd modules/MQTT-Broker
mako -l::www
```

The default `.preload` starts:

- MQTT over TLS on `8883`
- plain MQTT on `1883`
- a separate exact-subscription-only plain broker on `1884`

Mako's built-in default certificate is self-signed, so test clients must either trust it explicitly or disable certificate verification.

## Testing

Install the Python MQTT client if needed:

```bash
python -m pip install paho-mqtt
```

Run the full test suite from another terminal while Mako is running:

```bash
python design/test_mqtt_broker.py --tls --port 8883 --all
```

The full test covers:

- MQTT 3.1.1 and MQTT 5.0 connections
- TLS connections that accept the self-signed Mako certificate
- QoS 0 delivery
- `+` and `#` wildcard subscriptions
- `$` topic wildcard exclusion
- authentication accept/reject behavior
- publish policy allow/reject behavior
- cross-listener TLS-to-plain routing
- QoS 1 rejection
- invalid wildcard rejection
- MQTT 5 Topic Alias rejection

## How it works

`www/.preload` calls `mako.createloader(io)` so Lua can load modules from `www/.lua`. It then creates a SharkSSL server object from Mako's internal certificate and starts the broker with:

```lua
local mqttBroker,err=require("mqttbroker").create({
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
})
```

With `shark=shark`, the broker defaults to TLS port `8883`. With `plain=true`, it also opens a plain MQTT listener on `1883`. Both listeners share the same broker state and subscription table.

The broker routes only QoS 0 messages. It does not implement retained messages, persistent sessions, QoS 1/2 delivery state, shared subscriptions, topic aliases, or an application-side publish API.

## Notes / Troubleshooting

- If `mako -l::www` fails with a bind error, another Mako instance may already be using ports `1883`, `1884`, or `8883`.
- The default authentication callback allows anonymous clients for smoke testing. Supplied credentials must be `mqttuser` / `mqttpass`.
- Publications to topics beginning with `blocked/` are dropped by the example `onpublish` callback.
- The broker on port `1884` rejects any subscription containing `+` or `#`.
- For production TLS, replace Mako's self-signed test certificate with a certificate chain trusted by your clients.

## Disclaimer:

This code was generated using Codex. See the [design documentation](design/README.md) for additional details.

