### ESP32 Examples

Copy the files to an [Xedge-powered ESP32](https://realtimelogic.com/ba/ESP32/) by creating an LSP-enabled app and then uploading the files to the ESP32 by navigating to http://ip-address/rtl/apps/app-name/. Then drop the files into the Web File Manager window.

New to Lua?
Check out the online Lua tutorial: https://tutorial.realtimelogic.com/


- [blinkled.xlua](blinkled.xlua): This file is an XLua script that controls the blinking of an LED. It's commonly used in IoT applications and microcontroller programming to test hardware and software interaction.
- [camread.lsp](camread.lsp): This LSP (Lua Server Pages) file is a script that handles the reading of camera data. 
- [wscam.lsp](wscam.lsp): This LSP WebSocket example streams captured images to the connected browser(s).
- [pcmplayer.lsp](pcmplayer.lsp): This is an LSP script that playes PCM audio data in the browser.
- [uiservo.lsp](uiservo.lsp): This LSP script controls a servo motor through a real time web user interface.
- [bme280.xlua](bme280.xlua): XLua script for interacting with the BME280 sensor. The BME280 sensor is a digital pressure, temperature, and humidity sensor that is often used in weather station projects.
- [WeatherStationEoN.xlua](WeatherStationEoN.xlua): A complete MQTT (Sparkplug) enabled weather station system. See the [Sparkplug tutorial](../Sparkplug/README.md) for details.
