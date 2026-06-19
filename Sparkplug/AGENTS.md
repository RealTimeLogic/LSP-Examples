# AGENTS.md - Sparkplug

## Purpose

This example demonstrates MQTT Sparkplug B concepts with BAS/Mako/Xedge. It includes an Edge of Network node example (`EoN`) and a Sparkplug Explorer example that subscribes to Sparkplug topics and decodes protobuf payloads.

## Read First

- `README.md` for Sparkplug concepts, API examples, and run guidance.
- `EoN/.preload` for creating a Sparkplug client and publishing birth/data messages.
- `SparkplugExplorer/.preload` for MQTT subscription, protobuf schema loading, and payload decoding.
- `doc/wfm-sparkplug-modules.png` for the module overview diagram.

## Official Documentation (Source Of Truth)

Use the official Markdown documentation bundles for BAS, MQTT, Lua, threading, Mako Server, Xedge, and Sparkplug library usage. Do not invent MQTT or Sparkplug APIs.

- BAS API bundle: https://realtimelogic.com/downloads/basapi.md
- BAS tutorials bundle: https://realtimelogic.com/downloads/tutorials.md
- Mako Server tutorials bundle: https://makoserver.net/download/tutorials.md

Consult the Eclipse Sparkplug specification for Sparkplug topic and payload semantics.

## Runtime And Compatibility

- The Sparkplug library is available in Mako Server and Xedge according to the example README.
- Broker address, credentials, MQTT version, TLS, and network access must be configured for the target environment.
- The examples default to the public HiveMQ broker and demo credentials; do not treat these as production settings.

## Key Files

- `README.md`: overview of Sparkplug topic namespace, message types, client API, and example usage.
- `EoN/.preload`: creates a Sparkplug client, handles connection lifecycle events, publishes NBIRTH/DBIRTH and data messages, and handles NCMD/DCMD updates.
- `SparkplugExplorer/.preload`: starts an MQTT client, subscribes to `spBv1.0/#`, loads `sparkplug_b.proto`, decodes payloads, and pretty-prints results.
- `doc/wfm-sparkplug-modules.png`: architecture/module illustration.

## Change Guidance

- Keep Sparkplug topic naming aligned with the specification: namespace, group ID, message type, edge node ID, and optional device ID.
- Keep broker credentials and addresses configurable.
- Do not publish incomplete birth/data payloads; validate metrics include the expected names, values, and Sparkplug data types.
- When adding commands, update both the handler and the data publish path so state changes are visible to subscribers.

## Verification

Run the selected app root, for example:

```bash
cd Sparkplug
mako -l::SparkplugExplorer
```

or:

```bash
cd Sparkplug
mako -l::EoN
```

Verify the broker connection status in the console and confirm expected Sparkplug messages are published or decoded.
