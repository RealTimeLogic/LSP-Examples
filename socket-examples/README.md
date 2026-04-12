# Sockets and WebSockets Examples

## Overview

This directory collects several examples built on the [Barracuda App Server Lua socket library](https://realtimelogic.com/ba/doc/?url=SockLib.html). The examples cover plain sockets, UDP, NTP, WebSockets, blocking WebSocket services, cosocket-based services, and a simple Eliza chatbot.

## Files

- `www/index.lsp` - Landing page for the example bundle.
- `www/ntp.lsp` and `www/asyncntp.lsp` - Synchronous and asynchronous NTP examples.
- `www/udp.lsp` - UDP example.
- `www/wsecho.lsp` - WebSocket echo example.
- `www/Blocking-WS-Server/` - Blocking WebSocket example pages.
- `www/Cosocket-WS-Server/` - Cosocket-based WebSocket example pages.
- `www/eliza/` and `www/.lua/eliza.lua` - Browser UI and server-side logic for the Eliza example.
- `www/.lua/WebProxy.lua` and `www/.lua/WebServer.lua` - Additional socket-related helper examples.
- `www/.preload` - Startup logic used by the bundle.

## How to run

Start the examples with the Mako Server:

```bash
cd socket-examples
mako -l::www
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

After the server starts, open `http://localhost:portno`.

## How it works

The `www` app acts as a small example hub. Each LSP page or subdirectory exercises a different part of the BAS socket APIs, so you can inspect the server-side code in isolation without having to build a larger application around it first.

## Notes / Troubleshooting

- Some examples are blocking by design and are best run on a thread-enabled server such as Mako.
- WebSocket examples require a browser or client that can establish WebSocket connections successfully to the server.
