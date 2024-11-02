# AJAX Over WebSockets

## (Remote Procedure Calls (RPC) over WebSockets)

This repository contains example code for the [AJAX over WebSockets Tutorial](https://makoserver.net/articles/AJAX-over-WebSockets). These examples demonstrate how to set up AJAX requests using WebSockets for efficient, real-time communication between the client and server.

## Getting Started

To run the example, start the Mako Server in the project directory as follows:

```bash
cd AJAX-Over-WebSockets
mako -l::www
```


For detailed instructions on starting the Mako Server, refer to our c[command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and check the Mako Server documentation for [additional command line options](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

Once the server is running, open a browser and navigate to http://localhost:&lt;port_number&gt;, where &lt;port_number&gt; is the HTTP port used by the Mako Server (displayed in the console).

## Resources

The following files contain the code and examples for AJAX over WebSockets:

* www/index.html - The primary example, based on JQuery, demonstrating the AJAX WebSocket client library and code.
* www/promise.html - A modernized version of the example, using the native DOM, that leverages the Promise API and async/await for improved readability and asynchronous handling.
* www/service.lsp - The server-side script providing AJAX WebSocket service and server examples.

For further information on using these examples, please refer to the tutorial.
