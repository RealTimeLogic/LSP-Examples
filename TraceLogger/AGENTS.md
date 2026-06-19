# AGENTS.md - TraceLogger

## Purpose

This example is a local Mako Server TraceLogger client. It connects to the trace service on another BAS-enabled device and forwards the remote trace stream to the local Mako console or log.

## Read First

- `README.md` for the peer configuration and run workflow.
- `mako.conf` for the `trpeer` device name or IP address and TraceLogger UI setting.
- `www/.preload` for the trace-service connection, WebSocket upgrade, socket event loop, reconnect behavior, and trace forwarding.
- `www/index.lsp` for the redirect to the local TraceLogger UI.

## Official Documentation (Source Of Truth)

Use the official Markdown documentation bundles for Mako Server configuration, Lua, HTTP client, sockets, timers, threads, and TraceLogger-related BAS behavior. Do not invent BAS, Mako, Lua, socket, or trace APIs.

- BAS API bundle: https://realtimelogic.com/downloads/basapi.md
- BAS tutorials bundle: https://realtimelogic.com/downloads/tutorials.md
- Mako Server tutorials bundle: https://makoserver.net/download/tutorials.md

## Runtime And Compatibility

- This example is Mako-specific as written.
- It depends on `mako.conf`, Mako console/log behavior, local TraceLogger UI integration, and a local Mako process acting as the trace-forwarding client.
- The concept can be adapted to another BAS target, but do not mark this example as Xedge-compatible without redesigning configuration, logging, and deployment.

## Key Files

- `mako.conf`: sets `trpeer` and enables the local TraceLogger UI with `tracelogger=true`.
- `www/.preload`: reads `trpeer`, rejects localhost peers, probes the remote TraceLogger service, upgrades to WebSocket, converts the HTTP client to a socket, receives trace frames, logs trace lines, and reconnects after failures.
- `www/index.lsp`: redirects to `/rtl/tracelogger/`.

## Change Guidance

- Keep `trpeer` in `mako.conf`; do not hard-code device addresses in `www/.preload`.
- Do not point `trpeer` at `localhost` or `127.0.0.1`; the code intentionally rejects that to avoid self-connecting.
- If adding authentication support, handle the current `401` branch explicitly instead of hiding it behind a generic reconnect.
- Preserve reconnect throttling; avoid tight reconnect loops when the peer is offline.

## Verification

```bash
cd TraceLogger
mako -l::www
```

Then verify:

- `trpeer` points to a reachable BAS-enabled device.
- Remote trace output appears in the local console or `mako.log`.
- The local TraceLogger UI opens at `/rtl/tracelogger/`.
