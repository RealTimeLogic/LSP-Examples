# ESP32 Lua Examples

## Overview

The Barracuda App Server running on the ESP32 is packaged as the ready-to-use [Xedge32](https://realtimelogic.com/downloads/bas/ESP32/) development environment. These examples show how Lua, LSP, and XLua can be used for typical embedded tasks such as sensor access, camera streaming, audio capture, servo control, and MQTT integration.

![Xedge32 is built upon the Barracuda App Server C Code Library](https://realtimelogic.com/images/bas-esp32.png)

## Files

- `blinkled.xlua` - Source code for the tutorial [Your First Xedge32 Project](https://realtimelogic.com/articles/Your-First-Xedge32-Project).
- `CheckWiFi.lsp` - Source code for the tutorial [Debugging Wi-Fi Signal Strength with ESP32 and Xedge32](https://realtimelogic.com/articles/Debugging-WiFi-Signal-Strength-with-ESP32-and-Xedge32).
- `camtest.lsp` - Captures one camera image and returns it as JPEG each time the page is requested.
- `wscam.lsp` - Source code for the tutorial [Streaming ESP32-CAM Images to Multiple Browsers using WebSockets](https://realtimelogic.com/articles/Creating-Browser-Video-Streams-with-WebSockets-using-ESP32CAM).
- `mqttcam.xlua` and `mqttcam.html` - Source code for the tutorial [Streaming ESP32-CAM Images to Multiple Browsers via MQTT](https://realtimelogic.com/articles/Streaming-ESP32CAM-Images-to-Multiple-Browsers-via-MQTT).
- `pcmplayer.lsp` - Samples audio through the ADC at 20 kHz and streams it to the browser over WebSockets.
- `servo.lsp` - Introductory servo-control example.
- `uiservo.lsp` - Real-time web UI for servo control.
- `bme280.xlua` - BME280 temperature, humidity, and pressure example.
- `simulator/` - Supporting simulator assets for selected examples.

## How to run

Upload the files to an [Xedge-powered ESP32](https://realtimelogic.com/downloads/bas/ESP32/) by creating an LSP-enabled app and then navigating to:

```text
http://ip-address/rtl/apps/app-name/
```

From there, drag and drop the example files into the Web File Manager.

Important upload note:

- `.xlua` files run automatically when the application starts.
- `.lsp` files run only when a browser or other HTTP client requests them.

See the [Xedge documentation](https://realtimelogic.com/ba/doc/?url=Xedge.html) and the tutorial [Your First Xedge32 Project](https://realtimelogic.com/articles/Your-First-Xedge32-Project) for the complete app-creation workflow.

## How it works

These examples demonstrate both request-driven and startup-driven execution:

- LSP pages such as `camtest.lsp`, `wscam.lsp`, `pcmplayer.lsp`, `servo.lsp`, and `uiservo.lsp` respond to HTTP requests from the browser.
- XLua apps such as `blinkled.xlua`, `mqttcam.xlua`, and `bme280.xlua` start automatically when the app launches and are better suited for persistent device logic.

Together, they show how BAS can be used as both the embedded device runtime and the browser-facing application layer.

## Notes / Troubleshooting

- Do not upload `.xlua` files you do not intend to run, because they start automatically.
- `camtest.lsp` is the still-image camera example in this repo. Older references to `camread.lsp` are stale and have been corrected here.

Additional documentation:

- [What is Xedge32?](https://realtimelogic.com/downloads/bas/ESP32/)
- [Xedge Intro Video](https://youtu.be/1w_NDxzESo8)
- [Xedge Reference Manual](https://realtimelogic.com/ba/doc/?url=Xedge.html)
- [Xedge32 Reference Manual](https://realtimelogic.com/ba/ESP32/)
