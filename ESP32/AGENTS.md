# AGENTS.md - ESP32 Xedge32 Examples

## Purpose

This directory is a collection of small, hardware-focused examples for **Xedge32 only**. Xedge32 is the ESP32 distribution of the Barracuda App Server, and these examples demonstrate Lua Server Pages (`.lsp`) and startup XLua scripts (`.xlua`) running on ESP32-class devices.

This directory does **not** follow the usual one-example, one-application layout used by many other `LSP-Examples` directories. Treat each file in `misc/` as an independent script or page unless the file explicitly says it pairs with another file.

## Read First

Before changing anything, read these files in order:

1. `README.md` - current user-facing overview, file map, tutorial links, and upload guidance.
2. The specific file under `misc/`, `simulator/`, or `grafana/` that the user wants changed.
3. Any tutorial linked from `README.md` for that file.
4. Official Xedge32/BAS documentation for APIs used by the file.

Do not infer behavior from generic Lua. If something is unclear, consult the official documentation listed below before generating or modifying code.

## Official Documentation (Source Of Truth)

Use these consolidated files as the primary references:

- **ESP32/Xedge32 API reference (`esp32api.md`)**  
  https://realtimelogic.com/downloads/esp32api.md

- **BAS documentation bundle (`basapi.md`)**  
  https://realtimelogic.com/downloads/basapi.md

- **BAS tutorials bundle (`tutorials.md`)**  
  https://realtimelogic.com/downloads/tutorials.md

- **Mako Server tutorials bundle (`tutorials.md`)**  
  https://makoserver.net/download/tutorials.md

- **Xedge32 tutorial collection**  
  https://realtimelogic.com/xedge32-tutorials/

- **Xedge32 simulation with Mako Server**  
  https://realtimelogic.com/xedge32-tutorials/#Xedge4Mako

Reference priority:

1. `esp32api.md` for ESP32/Xedge32-specific APIs such as GPIO, I2C, PWM, ADC, camera, OTA, Wi-Fi, and related runtime behavior.
2. `basapi.md` for BAS/Lua/LSP/SMQ/MQTT API syntax, signatures, and behavior.
3. `tutorials.md` and the Xedge32 tutorial collection for architecture, setup, deployment, and example-specific guidance.
4. If guidance conflicts with API details, trust the API reference.

## Directory Shape

- `misc/` - independent Xedge32 scripts and pages. Upload only the files needed for the example being tested.
- `simulator/` - support files for running selected Xedge32 examples in Mako Server simulation mode.
- `grafana/` - Grafana dashboard JSON used by the ESP32/MySQL weather-station tutorial.
- `README.md` - user-facing explanation of the collection and tutorial references.

## Runtime Rules

- The primary target is **Xedge32 on ESP32 hardware**.
- `.lsp` files run when requested by a browser or HTTP client.
- `.xlua` files run automatically when the Xedge32 app starts; do not add or upload `.xlua` files casually.
- `misc/` is not one app. Do not make changes that assume all files are deployed together.
- Hardware constants such as GPIO pins, I2C pins, ADC channels, PWM timers, camera pin maps, MQTT topics, and broker names are example-specific and must be checked before reuse.
- Before modifying or helping a user run a hardware example, inspect the file for its hardware assumptions and summarize them: GPIO pins, I2C SDA/SCL pins, ADC unit/channel, PWM timer/channel, camera pin map, power requirements, and any MQTT/broker/topic settings. Ask the user whether their board is wired the same way or whether these values need to be changed.
- Long-running `.xlua` scripts should clean up timers, MQTT clients, cameras, and other resources with `onunload` where applicable.
- LSP pages that keep runtime objects across requests commonly use the persistent `page` table. Preserve this pattern unless there is a clear reason to change it.

## Key Files

- `misc/blinkled.xlua` - startup GPIO blink example using `esp32.gpio` and `ba.timer`.
- `misc/bme280.lsp` - single-file BME280 telemetry UI and JSON endpoint.
- `misc/bme280.xlua` - minimal startup BME280 sensor read test.
- `misc/camtest.lsp` - still-image camera test using `esp32.cam`.
- `misc/CheckWiFi.lsp` - Wi-Fi RSSI diagnostic page using `esp32.apinfo` and a raw WebSocket.
- `misc/mqttcam.xlua` - camera-to-MQTT publisher; pairs with `misc/mqttcam.html`.
- `misc/mqttcam.html` - standalone browser MQTT subscriber for JPEG frames.
- `misc/pcmplayer.lsp` - ADC audio sampling streamed to a browser over WebSockets.
- `misc/servo.lsp` - text/plain PWM servo sweep example.
- `misc/uiservo.lsp` - browser RoundSlider servo UI using SMQ over WebSockets.
- `misc/wscam.lsp` - camera streaming page using SMQ over WebSockets.
- `simulator/.preload` - Mako Server simulation bootstrap that stubs selected `esp32` APIs.
- `simulator/.lua/bme280.lua` - simulated BME280 module for desktop testing.
- `grafana/ESP32-MySQL-WeatherStation.json` - Grafana dashboard import file.

## Xedge32 API Guidance

Use `https://realtimelogic.com/downloads/esp32api.md` as the primary reference for ESP32-specific Xedge32 APIs used by these examples.

When working with SMQ examples:

- Server-side SMQ hubs are typically created with `require"smq.hub".create(...)`.
- Browser code uses `/rtl/smq.js` and `SMQ.Client(...)` in these examples.
- Preserve publish/subscribe topic names unless the user asks to change the protocol.
- If a page chunks binary data, such as camera frames, preserve the chunking/assembly topic protocol.

When working with MQTT examples:

- Keep the topic in `misc/mqttcam.xlua` and `misc/mqttcam.html` synchronized.
- Do not assume the public broker is appropriate for production.
- If changing broker, port, TLS, or topic settings, update both files and the README if the usage changes.

## Change Guidance

### Modifying an Existing Example

- Keep the file standalone unless it already depends on a paired file.
- Keep hardware settings near the top of the file when possible.
- If changing hardware-facing code, first identify the current pins/channels/configuration in the file and confirm the user's actual wiring before editing those values.
- Preserve tutorial comments and documentation links unless they become stale.
- For camera examples, test or document the board-specific camera config before changing streaming logic.
- For servo examples, keep PWM frequency, resolution, pulse width, and GPIO choices explicit.
- For WebSocket/SMQ examples, preserve cleanup behavior when clients disconnect.

### Adding a New Independent Script

- Put independent Xedge32 scripts and pages in `misc/`.
- Use `.lsp` for request-driven browser/API pages.
- Use `.xlua` only for startup logic that should run when the app starts.
- Add a short entry to `README.md` with purpose, hardware requirements, and any tutorial link.
- If the new example depends on another file, state the pairing explicitly in both files and in `README.md`.

### Updating Paths

If files are moved or renamed, search for references in:

- `README.md`
- tutorial comments inside `misc/*`
- GitHub URLs in external tutorial content, if the task includes site or CMS updates

Keep GitHub links aligned with the current repository paths, especially after moves between `ESP32/`, `ESP32/misc/`, `ESP32/simulator/`, and `ESP32/grafana/`.

## Verification

For Xedge32 hardware examples:

- Upload only the required files to an Xedge32 app.
- Confirm `.xlua` startup behavior after app start/restart.
- Request `.lsp` pages from the browser and check the browser console for JavaScript errors.
- Verify hardware behavior: GPIO, I2C, camera, ADC, PWM, Wi-Fi RSSI, MQTT, or SMQ as relevant.

For simulator-supported work:

- Use `simulator/` with Mako Server simulation mode as documented in the Xedge32 tutorial collection.
- Treat simulation as partial validation only; hardware-specific APIs still need real ESP32 testing.

For documentation-only changes:

- Check that every file listed in `README.md` exists.
- Check tutorial links and GitHub paths when files are moved.
- Do not claim hardware validation unless it was actually performed.
