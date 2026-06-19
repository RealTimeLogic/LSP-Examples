# AGENTS.md - LMQTT Broker

## Purpose

This example contains a compact Lua MQTT 3.1.1/5.0 broker for BAS-derived runtimes. It includes the reusable broker module, startup example with TLS and plain listeners, design notes, and a Python test suite.

Use this example when a BAS/Mako/Xedge app should host an in-process MQTT broker near application logic.

## Read First

1. `README.md` - capabilities, limits, run command, and test instructions.
2. `LMQTT-Broker.md` - broker API and feature scope.
3. `www/.lua/mqttbroker.lua` - broker implementation.
4. `www/.preload` - example broker startup and callbacks.
5. `design/README.md` and `design/design.md` when changing broker internals.

Do not invent MQTT, SharkSSL, BAS socket, or broker APIs.

## Official Documentation (Source Of Truth)

- **BAS documentation bundle (`basapi.md`)**  
  https://realtimelogic.com/downloads/basapi.md

- **BAS tutorials bundle (`tutorials.md`)**  
  https://realtimelogic.com/downloads/tutorials.md

- **Mako Server tutorials bundle (`tutorials.md`)**  
  https://makoserver.net/download/tutorials.md

Reference priority:

1. `basapi.md` for API syntax, signatures, and behavior.
2. `tutorials.md` for architecture, security, deployment, and tutorial context.
3. If tutorial guidance conflicts with API details, trust the API reference.

## Key Files

- `www/.lua/mqttbroker.lua` - reusable broker module.
- `www/.preload` - starts TLS broker on `8883`, plain broker on `1883`, and configures callbacks.
- `LMQTT-Broker.md` - public API reference and feature boundaries.
- `design/test_mqtt_broker.py` - Python paho-mqtt test suite.
- `design/` - design notes and AI prompt history.

## Change Guidance

- Preserve documented scope: QoS 0 routing is supported; QoS 1/2, retained messages, persistent sessions, shared subscriptions, and topic aliases are intentionally out of scope unless the user asks for a design expansion.
- If changing listener ports or TLS, update README and tests.
- Keep auth, publish policy, wildcard behavior, and cross-listener routing tests aligned with implementation.
- For production TLS, replace self-signed Mako test certificates with trusted certificates.
- Be explicit about Xedge deployment constraints such as listener ports and certificate storage.

## Run And Verify

```bash
cd MQTT-Broker
mako -l::www
```

Then from another terminal:

```bash
python -m pip install paho-mqtt
python design/test_mqtt_broker.py --tls --port 8883 --all
```
