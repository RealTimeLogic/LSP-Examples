# AJAX Over WebSockets

This is the companion example for the [AJAX over WebSockets](https://makoserver.net/articles/AJAX-over-WebSockets) tutorial.

Run the example, using the Mako Server, as follows:

```
cd AJAX-Over-WebSockets
mako -l::www
```

See the [Mako Server command line video tutorial](https://youtu.be/vwQ52ZC5RRg) for more information on how to start the Mako Server.


After starting the Mako Server, use a browser and navigate to http://localhost:portno, where portno is
the HTTP port number used by the Mako Server (printed in the console).

### Resources:
* www/index.html - The client AJAX library and the examples
* www/promise.html - Same as above, but redesigned to use the new JS Promise
* www/service.lsp - The AJAX WebSocket service and server side examples
