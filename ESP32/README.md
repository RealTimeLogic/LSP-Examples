### ESP32 Examples

Copy the files to an [Xedge-powered ESP32](https://realtimelogic.com/ba/ESP32/) by creating an LSP-enabled app and then uploading the files to the ESP32 by navigating to http://ip-address/rtl/apps/app-name/. Then drop the files into the Web File Manager window.

New to Lua?
Check out the online Lua tutorial: https://tutorial.realtimelogic.com/


- [blinkled.xlua](blinkled.xlua): An [XLua script](https://realtimelogic.com/ba/doc/?url=Xedge.html#apps), `blinkled.xlua` controls LED blinking. It's frequently used in IoT applications and microcontroller programming for testing hardware and software interaction.
- [camread.lsp](camread.lsp): This LSP (Lua Server Pages) file returns and displays a new camera image in the browser each time the browser window is refreshed.
- [wscam.lsp](wscam.lsp): A WebSocket example that continuously streams captured images to connected browsers.
- [pcmplayer.lsp](pcmplayer.lsp): This example activates the analog-to-digital converter and samples data at 20 kHz. Next, the data is sent via WebSockets to connected browsers, where a JavaScript-powered PCM player plays the incoming data.
- [uiservo.lsp](uiservo.lsp): This LSP script controls a servo motor through a real time web user interface.
- [bme280.xlua](bme280.xlua): XLua script for interacting with the BME280 sensor. The BME280 sensor is a digital pressure, temperature, and humidity sensor that is often used in weather station projects.
- [WeatherStationEoN.xlua](WeatherStationEoN.xlua): A complete MQTT Sparkplug enabled weather station system. or further details, refer to the [Sparkplug tutorial](../Sparkplug/README.md).
