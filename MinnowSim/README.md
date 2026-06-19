# MinnowSim

## Overview

This example is the companion code for the tutorial [Your First Embedded Single Page Application](https://realtimelogic.com/articles/Your-First-Embedded-Single-Page-Application). It demonstrates a small embedded-style single page application that communicates with server-side Lua over WebSockets.

When the example runs under Mako Server, it installs a simulated ESP32 GPIO environment so the same application logic can be exercised on a desktop. The SPA can authenticate, receive LED and temperature updates, send LED commands, make AJAX-style requests over the WebSocket channel, and upload binary firmware data.

## Files

- `www/.preload` - Application startup script. It simulates ESP32 GPIO when needed, manages connected SPA clients, handles JSON/WebSocket messages, implements AJAX-style request handlers, simulates temperature updates, and cleans up resources on unload.
- `www/index.lsp` - WebSocket upgrade endpoint. Browser WebSocket requests are handed to `app.newClient`; normal HTTP requests redirect to the SPA UI at `minnow/`.

## How to run

This example is only the server-side Lua/WebSocket part of the tutorial. The
browser SPA is in the separate
[MinnowServer](https://github.com/RealTimeLogic/MinnowServer) repository, so
Mako must load both applications at the same time:

- `MinnowServer/www` as `/minnow/` - the client-side SPA.
- `LSP-Examples/MinnowSim/www` as `/` - the simulated server-side device app.

If you do not already have both repositories, clone them into the same parent
directory:

```bash
git clone https://github.com/RealTimeLogic/MinnowServer
git clone https://github.com/RealTimeLogic/LSP-Examples
```

From that parent directory, start Mako with both apps:

```bash
mako -lminnow::MinnowServer/www -l::LSP-Examples/MinnowSim/www
```

If you are already inside the `LSP-Examples` directory and `MinnowServer` is a
sibling directory, use:

```bash
mako -lminnow::../MinnowServer/www -l::MinnowSim/www
```

After the server starts, open the printed local server URL in a browser. The
`MinnowSim/www/index.lsp` endpoint redirects normal browser requests to
`/minnow/`, where the SPA is served.

Default credentials:

- Username: `root`
- Password: `password`

## How it works

The server accepts WebSocket connections in `www/index.lsp` and passes the socket to `app.newClient` in `www/.preload`. The connection uses the BAS `JSONS` helper so client and server can exchange JSON messages and binary upload frames over the same WebSocket.

On startup, the Lua code creates simulated GPIO objects when the native `esp32` global is not available. LED button state changes are broadcast to connected SPA clients, and a timer coroutine periodically publishes simulated temperature updates.

The example also includes a small AJAX-over-WebSocket dispatcher. Messages such as `math/add`, `math/subtract`, `math/mul`, and `math/div` are handled on the server and returned to the requesting browser over the existing WebSocket connection.

## Packaging for Xedge

This example can be packaged as an Xedge app by creating a ZIP from the app directory, so the app files are at the ZIP root. See [Xedge App Deployment](../Xedge-App-Deployment/README.md) for the detailed deployment workflow.

```bash
cd www
zip -D -q -u -r -9 ../MinnowSim.zip .
```

Upload the generated ZIP with the Xedge App Upload tool.


## Notes

- This example is designed to be run as the `www` application root.
- The credential update flow stores `credentials.json` in the app storage area.
- Firmware upload frames are written to `FIRMWARE.bin` in the app storage area.
