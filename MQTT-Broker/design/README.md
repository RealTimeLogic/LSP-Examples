# LMQTT Broker Summary

This workspace contains a compact Lua MQTT broker for Barracuda App Server runtimes, including Mako Server and Xedge.

## Key Files

- `AI-prompt.md`: final implementation prompt and requirements. It now reflects the completed design, including TLS defaults, dual listeners, `auth`, `onpublish`, `onerror`, and `allowWildcards`.
- `design.md`: concise implementation design, call chain, state model, assumptions, and test status.
- `LMQTT-Broker.md`: API documentation for users of the broker.
- `www/.lua/mqttbroker.lua`: broker implementation.
- `www/.preload`: example application startup script. It creates a SharkSSL TLS listener, enables a plain listener, installs callbacks, and starts a second exact-subscription-only broker on port 1884.
- `test_mqtt_broker.py`: paho-mqtt integration and negative protocol tests.

## Current Broker Capabilities

- MQTT 3.1.1 and MQTT 5.0 clients.
- QoS 0 publish/subscribe routing.
- Clean sessions only.
- Plain MQTT default port `1883`.
- TLS MQTT default port `8883` when `shark` is set.
- Dual listener mode with shared broker state using `plain=true`.
- Optional username/password `auth` callback.
- Optional `onpublish` callback that can drop messages before routing.
- Optional `onerror` callback.
- Optional `allowWildcards=false` policy for rejecting `+` and `#` subscriptions.
- Minimal MQTT 5 compatibility, including property skipping and required zero-length property fields.

## Deliberately Out Of Scope

- QoS 1 and QoS 2 delivery state.
- Retained message storage.
- Persistent sessions.
- Will message delivery.
- Shared subscriptions.
- Topic aliases.
- MQTT 5 flow control.
- Per-client outbound queues.

## Validation

Run the full test suite against the TLS listener:

```powershell
python test_mqtt_broker.py --tls --port 8883 --all
```

The full test covers:

- MQTT 3.1.1 and MQTT 5 delivery.
- TLS with certificate verification disabled for the self-signed Mako test certificate.
- `+` and `#` wildcard routing.
- `$` topic wildcard exclusion.
- `auth` accept/reject behavior.
- `onpublish` allow/reject behavior.
- Cross-listener TLS-to-plain routing.
- QoS 1 rejection.
- Invalid wildcard SUBACK failure.
- MQTT 5 Topic Alias rejection.
- `allowWildcards=false`.

## Important Notes

Mako Server's internal certificate is self-signed. Test clients must trust it explicitly or disable certificate verification. The Python test script does the latter when `--tls` is used.

The `mqttRec` packet reader explicitly calculates overflow by byte count. This is important because BAS `ba.bytearray.copy` return values should not be interpreted as packet overflow.
