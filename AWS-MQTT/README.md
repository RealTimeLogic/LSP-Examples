# How to Connect to AWS IoT Core Using MQTT and ALPN

## Overview

This example accompanies the tutorial [How to Connect to AWS IoT Core using MQTT & ALPN](https://makoserver.net/articles/How-to-Connect-to-AWS-IoT-Core-using-MQTT-amp-ALPN). It demonstrates how to create an MQTT connection to AWS IoT Core using ALPN and mutual TLS. The same example is intended to work with the [Mako Server](https://makoserver.net/) and with [Xedge32](https://realtimelogic.com/downloads/bas/ESP32/).

If you are using an ESP32, also see the related tutorial [How to Connect ESP32 to AWS IoT Core Using MQTT](https://realtimelogic.com/articles/How-to-connect-ESP32-to-AWS-IoT-Core-Using-MQTT).

## Files

- `www/.preload` - Loads the MQTT example, creates the SharkSSL configuration, connects to AWS IoT Core, subscribes to two topics, and publishes JSON test messages once the connection is established.

## How to run

Prepare the AWS credentials and certificates first:

1. Follow the Amazon video tutorial referenced in the article.
2. Download [AmazonRootCA1.pem](https://www.amazontrust.com/repository/AmazonRootCA1.pem) and save it in the `www` directory.
3. Unzip `connect_device_package.zip`.
4. Copy `Demo_Thing.cert.pem` and `Demo_Thing.private.key` into the `www` directory.
5. Open `start.sh` from the AWS package and copy the broker endpoint after the `-e` option.
6. Open `www/.preload` and set `awsBroker = ""` to your broker endpoint.

Then start the example:

```bash
cd AWS-MQTT
mako -l::www
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

## How it works

The startup script creates a certificate store, loads the Amazon root CA and the device certificate/key pair, and builds a SharkSSL object for the AWS mutual TLS handshake. It then creates an MQTT client configured for port `443` with `alpn = "x-amzn-mqtt-ca"`. When the connection succeeds, the script subscribes to `topic_1` and `topic_2`, starts a timer, and publishes a JSON message to `topic_1` once per second. Incoming published data is decoded from JSON and printed to the trace output.

The script also unlinks the application directory when running as an LSP app so that the private key files are not exposed through HTTP.

## Notes / Troubleshooting

- The example will not connect until `awsBroker` is set correctly in `www/.preload`.
- The certificate and key filenames in the script must match the files you copied into `www/`.
- If you stop the app, `onunload()` cancels the timer and disconnects the MQTT client cleanly.
