# LMQTT Broker

LMQTT Broker is a compact MQTT 3.1.1 and MQTT 5.0 broker written in Lua for the [Barracuda App Server](https://realtimelogic.com/products/barracuda-application-server/) runtime. It is designed for BAS-derived environments such as [Mako Server](https://makoserver.net/), [Xedge](https://realtimelogic.com/products/xedge/), and embedded BAS applications that need a complimentary, scriptable MQTT broker close to the application logic.

Use it when a BAS, Mako Server, or Xedge project should host its own broker instead of only connecting to an external MQTT service.

## API Reference

Start here when integrating the broker:

- **[LMQTT-Broker.md](LMQTT-Broker.md)** - broker API, options, callbacks, TLS setup, in-process client API, and feature scope.

## What Is Included

- `www/.lua/mqttbroker.lua` - the broker module; copy this file into your project.
- `www/.preload` - startup example that creates a SharkSSL TLS listener, enables a plain listener, and installs broker callbacks.
- `design/test_mqtt_broker.py` - Python `paho-mqtt` test program.
- `LMQTT-Broker.md` - API reference and feature details.

## Fastest Path: Mako Developer Edition

The broker module is pre-integrated in the `mako.zip` included with the [Mako Developer Edition](https://makoserver.net/documentation/developer-package/). Use that package when you want the quickest host-side setup with Mako Server, Xedge, LSP-Claw, MQTT, and the LMQTT Broker already available.

The manual installation steps below are mainly for custom BAS, Mako Server, or Xedge projects where you want to copy the broker module yourself.

## Broker Capabilities

- MQTT 3.1.1 and MQTT 5.0 connection handling.
- QoS 0 publish/subscribe routing.
- MQTT over TLS with SharkSSL.
- Optional plain MQTT listener for development or controlled networks.
- Optional authentication callback.
- Optional publish policy callback.
- Optional wildcard-subscription blocking.
- In-process Lua client API for application-local publish/subscribe without loopback TCP.

The broker intentionally stays compact. It does not implement retained messages, persistent sessions, QoS 1/2 delivery state, shared subscriptions, topic aliases, or a general application-side publish API over the broker object. See [LMQTT-Broker.md](LMQTT-Broker.md) for details.

## Install the Module

If you are not using the Mako Developer Edition, copy the broker module into your project:

```text
www/.lua/mqttbroker.lua
```

When using a custom Mako Server setup, you may also integrate the module directly into `mako.zip` by adding it to the `.lua` directory inside the ZIP archive. Assuming `mako.zip` is in the current directory, run this from the `www` directory:

```bash
cd www
zip -r ../mako.zip .lua/mqttbroker.lua
```

## Run the Example

Start the example with Mako Server:

```bash
cd modules/MQTT-Broker
mako -l::www
```

The default `.preload` starts:

- MQTT over TLS on `8883`.
- Plain MQTT on `1883`.
- A separate exact-subscription-only plain broker on `1884`.

Mako's built-in default certificate is self-signed. Test clients must either trust it explicitly or disable certificate verification.

## How It Works

`www/.preload` calls `mako.createloader(io)` so Lua can load modules from `www/.lua`. It then creates a SharkSSL server object from Mako's internal certificate and starts the broker:

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

## Test the Broker

Install the Python MQTT client if needed:

```bash
python -m pip install paho-mqtt
```

Run the full test suite from another terminal while Mako is running:

```bash
python design/test_mqtt_broker.py --tls --port 8883 --all
```

The full test covers:

- MQTT 3.1.1 and MQTT 5.0 connections.
- TLS connections that accept the self-signed Mako certificate.
- QoS 0 delivery.
- `+` and `#` wildcard subscriptions.
- `$` topic wildcard exclusion.
- Authentication accept/reject behavior.
- Publish policy allow/reject behavior.
- Cross-listener TLS-to-plain routing.
- QoS 1 rejection.
- Invalid wildcard rejection.
- MQTT 5 Topic Alias rejection.

## Notes and Troubleshooting

- If `mako -l::www` fails with a bind error, another Mako instance may already be using ports `1883`, `1884`, or `8883`.
- The default authentication callback allows anonymous clients for smoke testing. Supplied credentials must be `mqttuser` / `mqttpass`.
- Publications to topics beginning with `blocked/` are dropped by the example `onpublish` callback.
- The broker on port `1884` rejects any subscription containing `+` or `#`.
- For production TLS, replace Mako's self-signed test certificate with a certificate chain trusted by your clients.

## Design Notes

This code was generated using Codex. See the [design documentation](design/README.md) for additional details.
