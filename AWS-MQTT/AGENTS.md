# AGENTS.md - AWS MQTT

## Purpose

This example demonstrates connecting to AWS IoT Core over MQTT using ALPN and mutual TLS. The startup script loads certificates from the app directory, builds the SharkSSL configuration, creates an MQTT client, subscribes to topics, and publishes JSON messages on a timer.

Use this example for AWS IoT Core MQTT setup, certificate handling, ALPN, and MQTT client lifecycle work.

## Read First

1. `README.md` - AWS setup steps, certificate filenames, broker configuration, and run command.
2. `www/.preload` - all runtime behavior for the example.

Do not invent BAS, MQTT, SharkSSL, certificate, timer, or JSON APIs.

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

- `www/.preload` - sets `awsBroker`, certificate filenames, creates the SharkSSL object, creates the MQTT client, subscribes to `topic_1` and `topic_2`, publishes JSON, and cleans up in `onunload()`.

## Change Guidance

- Never commit real AWS private keys, certificates, broker endpoints, or client secrets.
- Keep certificate filenames synchronized with the files copied into `www/`.
- Preserve `dir:unlink()` unless the user intentionally wants HTTP access to files in the app directory; it prevents private key exposure.
- If changing topics or payloads, update subscribe, publish, and trace handling together.
- If adapting to Xedge, move certificate and broker configuration into the target's secure configuration/storage model.

## Run And Verify

```bash
cd AWS-MQTT
mako -l::www
```

Before running, configure `awsBroker` and copy `AmazonRootCA1.pem`, the device certificate, and the private key into `www/`. Verify the console reports a successful MQTT connection, subscriptions, and periodic publishes.
