# AGENTS.md - socket-examples

## Purpose

This directory collects BAS socket and WebSocket examples. It demonstrates blocking sockets, UDP, NTP, WebSocket echo flows, blocking WebSocket services, cosocket services, a small proxy, a simple HTTP server, and an Eliza chatbot.

## Read First

- `README.md` for the example inventory and run command.
- `www/index.lsp` for the landing page and links to each example.
- `www/.preload` for startup loading of helper modules.
- The specific LSP page or helper module for the socket behavior being changed.

## Official Documentation (Source Of Truth)

Use the official Markdown documentation bundles for BAS socket, WebSocket, cosocket, thread, Lua, LSP, and Mako/Xedge APIs. Do not invent socket or WebSocket APIs.

- BAS API bundle: https://realtimelogic.com/downloads/basapi.md
- BAS tutorials bundle: https://realtimelogic.com/downloads/tutorials.md
- Mako Server tutorials bundle: https://makoserver.net/download/tutorials.md

## Runtime And Compatibility

- The bundle runs with Mako using `mako -l::www`.
- Many socket/cosocket patterns are portable to Xedge when the target supports the required network operations.
- Blocking examples should be reviewed carefully on constrained targets, especially Xedge32 or other embedded deployments.

## Key Files

- `www/index.lsp`: example hub and generated links for local proxy/server addresses.
- `www/.preload`: loads helper modules from `www/.lua` after server startup.
- `www/ntp.lsp` and `www/asyncntp.lsp`: synchronous and asynchronous NTP clients.
- `www/udp.lsp`: UDP example.
- `www/wsecho.lsp`: WebSocket echo example.
- `www/Blocking-WS-Server/ws.lsp`: blocking WebSocket server example.
- `www/Cosocket-WS-Server/ws.lsp`: cosocket-based WebSocket server example.
- `www/.lua/WebProxy.lua` and `www/.lua/WebServer.lua`: helper examples loaded during startup.
- `www/eliza/` and `www/.lua/eliza.lua`: WebSocket chatbot example.

## Change Guidance

- Keep each socket behavior isolated in its own LSP page or helper module.
- Prefer cosockets for designs that manage several simultaneous sockets.
- Do not copy blocking request-time patterns into production-style embedded examples without explaining the thread/resource cost.
- When changing generated addresses in `www/index.lsp`, preserve IPv6 localhost handling and host/port derivation.

## Verification

```bash
cd socket-examples
mako -l::www
```

Then open the printed URL and test the specific example page. For WebSocket changes, verify connection open, message exchange, and clean close behavior from the browser.
