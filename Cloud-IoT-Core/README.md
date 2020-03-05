# Connecting to Google Cloud IoT Core's MQTT Bridge

This example shows how to connect to [Google Cloud IoT Core's MQTT Bridge](https://cloud.google.com/iot/docs/how-tos/mqtt-bridge). The example automatically creates the required private and public ECC keys required for authentication and uses the [JSON Web Token library](https://realtimelogic.com/ba/doc/?url=auxlua.html#ba_crypto_JWT) when authenticating with the MQTT Bridge.

The example includes several LSP files that simplify your understanding of using the Google MQTT Bridge. The example also includes an LSP for publishing data to the MQTT Bridge; however, the example concludes at the following:

![MQTT Bridge](https://cloud.google.com/iot/resources/gateway-arch.png "Google's MQTT Bridge")

Once the data is at the MQTT Bridge, it is in the Google Cloud, and you can consume it the way you want. You may use any applicable tutorial for routing the device messages sent to the MQTT Bridge to your preferred service, such as a database.

Run the example, using the Mako Server, as follows:

```
cd Cloud-IoT-Core
mako -l::www
```

See the [Mako Server command line video tutorial](https://youtu.be/vwQ52ZC5RRg) for more information on how to start the Mako Server.

After starting the Mako Server, use a browser and navigate to
http://localhost:portno, where portno is the HTTP port number used by
the Mako Server (printed in the console).


## Files
* www/google/roots.pem  - Google root CA cert: https://pki.goog/roots.pem
* www/.preload -- The core of the implementation. Make sure to study this code.

The following two files, which are included by all LSP pages, provide the application style and a menu as explained in the [Dynamic Navigation Menu](https://makoserver.net/articles/Dynamic-Navigation-Menu) tutorial.

* www/.header.lsp -- HTML template and menu generation.
* www/footer.shtml -- Balances .header.lsp with closing HTML tags.

The LSP pages:

* www/index.lsp - shows how to use the example.
* www/regdev.lsp - Prints the public certificate you must use when registering the device with Google Cloud.
* www/connect.lsp - Enbles user input and verifies the initial MQTT connection.
* www/publish.lsp - Publishes MQTT messages to the MQTT Bridge.
