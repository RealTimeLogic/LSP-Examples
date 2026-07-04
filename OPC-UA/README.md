# OPC UA Lua Examples

This directory contains Lua examples for [Real Time Logic's OPC UA stack](https://realtimelogic.com/products/opc-ua/). The examples are referenced by the **[OPC UA documentation](https://realtimelogic.com/ba/opcua/index.html)** and are kept here so they are publicly available outside the documentation.

The examples are organized by topic:

| Directory | Purpose |
| --- | --- |
| `client/` | OPC UA client connection, session, browse, read, write, authentication, and security-policy examples. |
| `server/` | OPC UA server, address-space, authentication, XML model, data-source, and method examples. |
| `pubsub/` | MQTT PubSub examples. |
| `tutorial/` | Step-by-step learning examples that run locally with Mako Server and do not require hardware. |

Standalone helper files:

| File | Purpose |
| --- | --- |
| `node_id.lua` | NodeId string and table conversion examples. |
| `create_certificate_basic128rsa15.lua` | Certificate generation example. |

## Learning Examples

Run the standalone learning examples from this directory:

```bash
mako tutorial/run_standalone.lua
```

For the client learning examples, start the local learning server in one
terminal:

```bash
mako -l::tutorial/learning_server
```

Then run the client examples from another terminal:

```bash
mako tutorial/06_client_read.lua
mako tutorial/07_client_write.lua
mako tutorial/08_method_call.lua
```

Stop the learning server with `Ctrl+C` when done.

## PubSub API Examples

The examples in `pubsub/` use a local
[MQTT broker](https://github.com/RealTimeLogic/LSP-Examples/tree/master/MQTT-Broker)
instead of a public external broker. The easiest setup is the
[Mako Server mako.zip Developer Edition](https://makoserver.net/documentation/developer-package/),
which includes the broker module used by these examples.

Run the examples from the `pubsub` directory:

```bash
cd pubsub
mako mqtt_publish_node_subscribe.lua
mako mqtt_publish_serverless.lua
mako mqtt_subscribe.lua
```

The examples stop immediately with a clear error message if the `mqttbroker`
module cannot be loaded. In that case, install the Developer Edition `mako.zip`
or copy the broker from the MQTT-Broker example.

## PubSub Learning Examples

The PubSub tutorial examples use the Lua MQTT broker module included with the
[Mako Server mako.zip Developer Edition](https://makoserver.net/documentation/developer-package/).
This is the easiest way to test the examples locally because no external MQTT
broker is required.

From `LSP-Examples/OPC-UA`, run the PubSub learning examples with:

```bash
cd tutorial
mako run_pubsub.lua
```

The examples load shared tutorial code from `tutorial/.lua/pubsub_common.lua`
using `mako.createloader(io)` and `require()`. They stop immediately with a
clear error message if the `mqttbroker` module cannot be loaded. In that case,
install the Developer Edition `mako.zip` or copy the broker from
[MQTT-Broker](https://github.com/RealTimeLogic/LSP-Examples/tree/master/MQTT-Broker).

> **Warning:** The PubSub examples require an
> [MQTT broker](https://github.com/RealTimeLogic/LSP-Examples/tree/master/MQTT-Broker).
> The easiest test setup is the
> [Mako Server mako.zip Developer Edition](https://makoserver.net/documentation/developer-package/),
> which includes the broker module used by these examples.
