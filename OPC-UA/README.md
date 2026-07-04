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
