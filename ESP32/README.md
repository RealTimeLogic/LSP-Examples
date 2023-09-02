### ESP32 Lua Examples

The Barracuda App Server, running on the ESP32 microcontroller, is packaged as a ready-to-use Integrated Development Environment (IDE) known as [Xedge32](https://realtimelogic.com/downloads/bas/ESP32/). With Xedge32, programming embedded systems becomes accessible to all, not just to embedded C/C++ experts.

![Xedge32 is built upon the Barracuda App Server C Code Library](https://realtimelogic.com/images/bas-esp32.png)

**Examples:**

- [blinkled.xlua](blinkled.xlua): The source code for the tutorial [Your First Xedge32 Project](https://realtimelogic.com/articles/Your-First-Xedge32-Project)
- [camread.lsp](camread.lsp): This LSP (Lua Server Pages) file returns and displays a new camera image in the browser each time the browser window is refreshed.
- [wscam.lsp](wscam.lsp): A WebSocket example that continuously streams captured images to connected browsers.
- [mqttcam.xlua](mqttcam.xlua) and [mqttcam.html](mqttcam.html): The source code for the tutorial [Streaming ESP32-CAM Images to Multiple Browsers via MQTT](https://realtimelogic.com/articles/Streaming-ESP32CAM-Images-to-Multiple-Browsers-via-MQTT).
- [pcmplayer.lsp](pcmplayer.lsp): This example activates the analog-to-digital converter and samples data at 20 kHz. Next, the data is sent via WebSockets to connected browsers, where a JavaScript-powered PCM player plays the incoming data.
- [servo.lsp](servo.lsp): Introductory servo example with detailed explanation.
- [uiservo.lsp](uiservo.lsp): This LSP script controls a servo motor through a real time web user interface.
- [bme280.xlua](bme280.xlua): XLua script for interacting with the BME280 sensor. The BME280 sensor is a digital pressure, temperature, and humidity sensor that is often used in weather station projects.
- [WeatherStationEoN.xlua](WeatherStationEoN.xlua): A complete MQTT Sparkplug enabled weather station system. For further details, refer to the [Sparkplug tutorial](../Sparkplug/README.md).

**How to upload the examples:**

Copy the files to an [Xedge-powered ESP32](https://realtimelogic.com/downloads/bas/ESP32/) by creating an LSP-enabled app and then uploading the files to the ESP32 by navigating to http://ip-address/rtl/apps/app-name/. Then drop the files into the Web File Manager window. Do not upload xlua files you do not intend to run since xlua files automatically run when the application starts. LSP files, on the other hand, only run when accessed by a browser or any other HTTP client. See the [Xedge documentation](https://realtimelogic.com/ba/doc/?url=Xedge.html) for details. See the tutorial [Your First Xedge32 Project](https://realtimelogic.com/articles/Your-First-Xedge32-Project) for how to create Xedge applications.

**Documentation:**

- [What is Xedge32?](https://realtimelogic.com/downloads/bas/ESP32/)
- [Xedge Intro Video](https://youtu.be/1w_NDxzESo8)
- [Xedge Reference Manual](https://realtimelogic.com/ba/doc/?url=Xedge.html)
- [Xedge32 Reference Manual](https://realtimelogic.com/ba/ESP32/)
