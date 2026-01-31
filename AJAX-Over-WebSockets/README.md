# REST / AJAX / RPC – different names, same idea
## REST / AJAX / RPC over WebSockets

This repository contains example code for the [AJAX over WebSockets](https://makoserver.net/articles/AJAX-over-WebSockets) tutorial. Despite the different terminology, this example demonstrates the same fundamental interaction model as REST and RPC APIs: a browser calling server-side logic asynchronously without reloading the page.

At a conceptual level, **REST**, **AJAX**, and **RPC (Remote Procedure Calls)** all describe ways for a browser to communicate with a server in the background:

- **AJAX** describes *how* the browser sends requests (asynchronously, without page reloads)
- **REST** and **RPC** describe *how the API is modeled*
- The runtime behavior is the same: request → server processing → response

This example uses an **RPC-style programming model** implemented over **WebSockets**, but it fulfills the same role as traditional HTTP-based REST or AJAX APIs. The main difference is that WebSockets provide a persistent, bidirectional connection, eliminating repeated HTTP request overhead.

---

## Why WebSockets?

WebSockets establish a long-lived connection between the browser and server, making them ideal for:

- Low-latency, interactive applications
- Real-time updates
- Efficient request/response exchanges without repeated connection setup

In this example, WebSockets are used as a transport layer. On top of that transport, the API behaves like a familiar AJAX or RPC interface.

---

## Getting started

To run the example, start the Mako Server in the project directory:

```bash
cd AJAX-Over-WebSockets
mako -l::www
```

For more details on starting the Mako Server, see:

- The command-line video tutorial: https://youtu.be/vwQ52ZC5RRg  
- Mako Server command-line options: https://realtimelogic.com/ba/doc/en/Mako.html#cmdline

Once the server is running, open a browser and navigate to:

```
http://localhost:<port_number>
```

The port number is displayed in the Mako Server console output.

---

## Example files

The following files demonstrate AJAX / RPC-style communication over WebSockets:

- **www/index.html**  
  The original example, based on jQuery, demonstrating the AJAX WebSocket client library.

- **www/promise.html**  
  A modernized version using the native DOM APIs, Promises, and `async / await` for clearer asynchronous code.

- **www/service.lsp**  
  The server-side Lua Server Pages (LSP) script implementing the WebSocket-based service logic.

---

## How this relates to REST

Although the API is not expressed as REST-style URLs, the interaction pattern is equivalent:

- The browser sends a request for server-side processing
- The server executes logic and returns structured data
- The browser updates the UI without a page reload

Many real-world REST APIs are effectively RPC expressed through HTTP verbs and URLs. This example shows the same pattern implemented more directly using WebSockets as the transport.

---

## Learn more

For a detailed walkthrough of the concepts and code, see the full tutorial:

https://makoserver.net/articles/AJAX-over-WebSockets

## See Also

- [REST / AJAX / RPC over SMQ](../SMQ-examples/RPC/README.md)
