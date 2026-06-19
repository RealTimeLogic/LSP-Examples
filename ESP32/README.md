# ESP32 Xedge32 Examples

## Overview

This directory contains examples that target **Xedge32 only**: the ESP32-ready distribution of the Barracuda App Server. The examples show how Xedge32 can run Lua Server Pages (`.lsp`) and startup XLua scripts (`.xlua`) directly on ESP32-class hardware.

The files are intentionally small and hardware-focused. They demonstrate GPIO, Wi-Fi diagnostics, camera capture, WebSocket/SMQ streaming, MQTT publishing, ADC audio streaming, PWM servo control, BME280 telemetry, and related visualization assets.

![Xedge32 is built upon the Barracuda App Server C Code Library](https://realtimelogic.com/images/bas-esp32.png)

## Directory Layout

```text
ESP32/
  README.md
  misc/       # Independent Xedge32 scripts/pages; upload selected files to an Xedge32 app
  simulator/  # Support files for simulating selected ESP32 APIs during development
  grafana/    # Grafana dashboard JSON used by the weather-station tutorial
```

## How To Use These Examples

Create an app in the Xedge32 Web File Manager, then upload the files needed by the example you want to run.

Typical app URL:

```text
http://esp32-ip/rtl/apps/app-name/
```

Upload notes:

- `.lsp` files run when a browser or HTTP client requests them.
- `.xlua` files run automatically when the Xedge32 app starts.
- Do not upload `.xlua` files unless you want them to start with the app.
- Most examples need hardware-specific GPIO, I2C, camera, ADC, or PWM settings adjusted before use.
- `misc/` is a collection of independent examples, not one app that should be uploaded all at once.

## Examples In `misc/`

Sorted alphabetically:

### `blinkled.xlua`

Startup XLua example that blinks an LED using a coroutine timer.

- Demonstrates: GPIO output, `ba.timer`, coroutine-style timing.
- Hardware: LED connected to GPIO 4 and ground by default.
- Related tutorial: [Your First Xedge32 Project](https://realtimelogic.com/articles/Your-First-Xedge32-Project).

### `bme280.lsp`

Single-file BME280 telemetry web UI and JSON endpoint.

- Demonstrates: I2C sensor access, persistent `app` state, JSON endpoints, browser polling, chart rendering.
- Hardware: BME280 sensor on I2C. GPIO settings are defined near the top of the file.
- Browser assets: Tailwind CSS and Chart.js from CDNs.
- Related tutorial: [Vibe Coding Embedded Web Interfaces](https://realtimelogic.com/articles/Vibe-Coding-Embedded-Web-Interfaces).

### `bme280.xlua`

Minimal startup test for a BME280 sensor.

- Demonstrates: loading the `bme280` Lua module, creating a sensor instance, reading temperature/humidity/pressure, closing the device.
- Hardware: BME280 sensor on I2C. Edit `SDA_GPIO`, `SCL_GPIO`, and `BME280_I2C_ADDR` as needed.
- Use this before building a larger BME280 app.
- Related tutorial: [ESP32 and MySQL Cloud Integration: Visualizing Weather Data](https://realtimelogic.com/articles/ESP32-and-MySQL-Cloud-Integration-Visualizing-Weather-Data).

### `camtest.lsp`

Still-image camera test page.

- Demonstrates: `esp32.cam`, one-shot image capture, returning JPEG data directly from an LSP page.
- Hardware: ESP32 camera module. The file includes a sample config for a FREENOVE ESP32-S3 WROOM CAM board.
- Use this to validate camera pin settings before trying streaming examples.
- Related tutorial: [Streaming ESP32-CAM Images to Multiple Browsers via MQTT](https://realtimelogic.com/articles/Streaming-ESP32CAM-Images-to-Multiple-Browsers-via-MQTT).

### `CheckWiFi.lsp`

Wi-Fi diagnostic page that shows AP information and streams RSSI changes to the browser.

- Demonstrates: `esp32.apinfo`, WebSocket upgrade with `ba.socket.req2sock`, live browser updates.
- Hardware: ESP32 connected to Wi-Fi.
- Related tutorial: [Debugging Wi-Fi Signal Strength with ESP32 and Xedge32](https://realtimelogic.com/articles/Debugging-WiFi-Signal-Strength-with-ESP32-and-Xedge32).

### `mqttcam.html`

Standalone browser page that subscribes to JPEG frames over MQTT.

- Demonstrates: browser-side MQTT over secure WebSockets using MQTT.js.
- Pairs with: `mqttcam.xlua`.
- Important: update the MQTT topic so it matches `mqttcam.xlua`.
- This file can be opened directly in a browser; it does not need to be served by Xedge32.
- Related tutorial: [Streaming ESP32-CAM Images to Multiple Browsers via MQTT](https://realtimelogic.com/articles/Streaming-ESP32CAM-Images-to-Multiple-Browsers-via-MQTT).

### `mqttcam.xlua`

Startup XLua script that publishes ESP32 camera frames to an MQTT broker.

- Demonstrates: `esp32.cam`, MQTT client publishing, timer-based capture loop, threaded camera reads, cleanup with `onunload`.
- Hardware: ESP32 camera module. Validate camera settings with `camtest.lsp` first.
- Broker: defaults to the public HiveMQ broker.
- Pairs with: `mqttcam.html`.
- Related tutorial: [Streaming ESP32-CAM Images to Multiple Browsers via MQTT](https://realtimelogic.com/articles/Streaming-ESP32CAM-Images-to-Multiple-Browsers-via-MQTT).

### `pcmplayer.lsp`

Browser audio streaming page.

- Demonstrates: ADC sampling, WebSocket streaming, multiple browser clients, browser PCM playback.
- Hardware: microphone or audio source connected to the configured ADC input.
- Browser asset: PCMPlayer from a CDN.
- Related tutorial collection: [Master Embedded Development with Lua on ESP32 Using Xedge32](https://realtimelogic.com/xedge32-tutorials/).

### `servo.lsp`

Text/plain servo sweep and PWM calculation example.

- Demonstrates: PWM timer setup, PWM channel setup, servo duty-cycle calculation, persistent page timer state.
- Hardware: standard servo on GPIO 14 by default.
- Behavior: requesting the page starts/stops the sweep timer.
- Read this before using `uiservo.lsp`.
- Related tutorial: [Designing Your First Professional Embedded Web Interface](https://realtimelogic.com/articles/Designing-Your-First-Professional-Embedded-Web-Interface).

### `uiservo.lsp`

Interactive browser UI for servo control.

- Demonstrates: RoundSlider UI, SMQ over WebSockets, multi-browser synchronization, PWM servo control.
- Hardware: standard servo on GPIO 14 by default.
- Browser assets: jQuery, SMQ JavaScript client, and RoundSlider.
- Related tutorial: [Designing Your First Professional Embedded Web Interface](https://realtimelogic.com/articles/Designing-Your-First-Professional-Embedded-Web-Interface).
- Related design pattern: [Modern Approach to Embedding a Web Server in a Device](https://realtimelogic.com/articles/Modern-Approach-to-Embedding-a-Web-Server-in-a-Device).

### `wscam.lsp`

Camera streaming page using SMQ over WebSockets.

- Demonstrates: `esp32.cam`, SMQ hub, WebSocket upgrade, JPEG chunking, subscriber observation, RSSI updates.
- Hardware: ESP32 camera module. The file includes a sample config for Seeed Studio XIAO ESP32S3 Sense.
- Use `camtest.lsp` first to validate camera settings.
- Related tutorial: [Streaming ESP32-CAM Images to Multiple Browsers using WebSockets](https://realtimelogic.com/articles/Creating-Browser-Video-Streams-with-WebSockets-using-ESP32CAM).

## `grafana/`

### `ESP32-MySQL-WeatherStation.json`

Grafana dashboard definition for the ESP32/MySQL weather-station tutorial.

- Demonstrates: importing a ready-made Grafana dashboard.
- Expected datasource: MySQL.
- Related tutorial: [ESP32 and MySQL Cloud Integration: Visualizing Weather Data](https://realtimelogic.com/articles/ESP32-and-MySQL-Cloud-Integration-Visualizing-Weather-Data).

## `simulator/`

The simulator folder contains support files for running selected Xedge32 examples in simulation mode using Mako Server. This makes it possible to test parts of the Xedge32 application flow on a desktop before deploying to ESP32 hardware.

- `simulator/.preload` creates stub `esp32` APIs such as GPIO, OTA, MAC address, execute/restart, and camera capture.
- `simulator/.lua/bme280.lua` provides a simulated BME280 module that returns changing temperature, humidity, and pressure readings.

The main examples in this directory are still Xedge32 examples. Treat the simulator as support tooling, not the primary target runtime. For setup details, see [Running Xedge32 Examples in Mako Server Simulation Mode](https://realtimelogic.com/xedge32-tutorials/#Xedge4Mako).

## Hardware And Configuration Checklist

Before running an example, check:

- Camera examples: board-specific camera pin mapping and frame size.
- BME280 examples: I2C port, SDA/SCL GPIOs, and sensor address.
- Servo examples: signal GPIO and external servo power requirements.
- Audio example: ADC unit/channel and sample-rate expectations.
- MQTT example: broker, topic, and network access.
- CDN-backed pages: Internet access from the browser for JavaScript/CSS dependencies.

## Documentation

- [What is Xedge32?](https://realtimelogic.com/downloads/bas/ESP32/)
- [Xedge32 Reference Manual](https://realtimelogic.com/ba/ESP32/)
- [Xedge Reference Manual](https://realtimelogic.com/ba/doc/?url=Xedge.html)
- [Xedge Intro Video](https://youtu.be/1w_NDxzESo8)
