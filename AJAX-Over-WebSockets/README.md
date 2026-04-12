# REST / AJAX / RPC Over WebSockets

## Overview

This example accompanies the tutorial [AJAX over WebSockets](https://makoserver.net/articles/AJAX-over-WebSockets). Even though the names REST, AJAX, and RPC come from different traditions, this example shows the same underlying pattern: the browser calls server-side logic asynchronously and updates the page without a full reload.

WebSockets are used here as the transport layer, which makes the connection persistent and bidirectional. That removes the repeated setup cost of individual HTTP requests while still giving the browser a familiar request/response programming model.

## Files

- `www/.preload` - Startup logic for the example app.
- `www/index.html` - Original browser example based on jQuery and the AJAX WebSocket client library.
- `www/promise.html` - Modernized browser example using native DOM APIs, Promises, and `async` / `await`.
- `www/service.lsp` - Server-side LSP page that upgrades the request to a WebSocket and exposes the example RPC-style service.

## How to run

Start the example with the Mako Server:

```bash
cd AJAX-Over-WebSockets
mako -l::www
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/en/Mako.html#cmdline).

After the server starts, open:

```text
http://localhost:portno
```

where `portno` is the HTTP port printed in the Mako console.

## How it works

`service.lsp` upgrades eligible HTTP requests to a WebSocket by calling `ba.socket.req2sock(request)`. Once the socket is established, the page runs a loop that reads JSON messages, resolves the requested service path against a Lua table of exported functions, executes the function with `pcall(...)`, and writes back a JSON response containing the result or error.

The browser examples then use that WebSocket channel as if it were an AJAX or RPC endpoint. In practical terms, the browser sends a request, the server runs Lua code, and the browser receives structured data it can use to update the UI.

### Why WebSockets?

WebSockets establish a long-lived connection between the browser and the server, making them well suited for:

- low-latency interactive applications
- real-time updates
- efficient request/response exchanges without repeated connection setup

In this example, WebSockets are used as the transport. On top of that transport, the programming model still feels like AJAX or RPC.

### How this relates to REST

Although the API is not expressed as REST-style URLs, the interaction pattern is equivalent:

- the browser sends a request for server-side processing
- the server executes the logic and returns structured data
- the browser updates the UI without a full reload

Many real-world REST APIs are effectively RPC expressed through HTTP verbs and URLs. This example shows the same pattern implemented more directly using a persistent WebSocket channel.

## Notes / Troubleshooting

- If you access `service.lsp` without a WebSocket handshake, the page returns `404` because it is meant to act as a socket endpoint, not as a regular HTML page.
- `promise.html` is the easier version to study if you want the modern browser-side flow first.
- Full tutorial: https://makoserver.net/articles/AJAX-over-WebSockets
- Related example: [REST / AJAX / RPC over SMQ](../SMQ-examples/RPC/README.md)
