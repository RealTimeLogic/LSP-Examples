# How to Connect to AWS IoT Core using MQTT & ALPN

This is the companion example for the tutorial:
[How to Connect to AWS IoT Core using MQTT & ALPN](https://makoserver.net/articles/How-to-Connect-to-AWS-IoT-Core-using-MQTT-amp-ALPN).
Please refer to this tutorial for the details.

## Instructions:

1. Follow the Amazon video tutorial
2. Download [AmazonRootCA1.pem](https://www.amazontrust.com/repository/AmazonRootCA1.pem) and save the certificate in the www directory.
3. Unzip connect_device_package.zip
4. Copy Demo_Thing.cert.pem and Demo_Thing.private.key to the www directory
5. Open start.sh (from the ZIP file) in an editor; copy the MQTT broker name (the name is after the -e option)
6. Open www/.preload in an editor; Set the broker name in the empty string: awsBroker = ""
7. Run the example

This example is compatible with the [Mako Server](https://makoserver.net/) and [Xedge32](https://realtimelogic.com/downloads/bas/ESP32/). See the tutorial [How to connect ESP32 to AWS IoT Core Using MQTT](https://realtimelogic.com/articles/How-to-connect-ESP32-to-AWS-IoT-Core-Using-MQTT) if you are using an ESP32.

Run the example, using the Mako Server, as follows:

``` shell
cd AWS-MQTT
mako -l::www
```

For detailed instructions on starting the Mako Server, check out our [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and review the server's [command line options](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp) in our documentation.
