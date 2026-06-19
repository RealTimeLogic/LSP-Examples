# AGENTS.md - AJAX Over WebSockets

## Purpose

This example shows an AJAX/RPC-style request-response API over a persistent WebSocket transport. The browser calls named server-side Lua functions asynchronously, and `www/service.lsp` upgrades WebSocket requests with `ba.socket.req2sock(request)`.

Use this example when the user wants lightweight browser-to-Lua RPC over WebSockets, not plain HTTP AJAX and not SMQ.

## Read First

1. `README.md` - overview, run command, and tutorial link.
2. `www/service.lsp` - WebSocket upgrade and server-side RPC dispatch.
3. `www/promise.html` - modern native JavaScript Promise/async client.
4. `www/index.html` - older jQuery client kept for comparison.
5. `www/.preload` - app startup message.

Do not invent BAS, socket, WebSocket, LSP, JSON, or browser APIs. If API details are unclear, use the official Markdown documentation bundles below.

## Official Documentation (Source Of Truth)

- **BAS documentation bundle (`basapi.md`)**  
  https://realtimelogic.com/downloads/basapi.md

- **BAS tutorials bundle (`tutorials.md`)**  
  https://realtimelogic.com/downloads/tutorials.md

- **Mako Server tutorials bundle (`tutorials.md`)**  
  https://makoserver.net/download/tutorials.md

Reference priority:

1. `basapi.md` for LSP, `ba.socket`, WebSocket upgrade, JSON, and Lua API details.
2. `tutorials.md` for architecture and tutorial context.
3. If tutorial guidance conflicts with API details, trust `basapi.md`.

## Key Files

- `www/service.lsp` - WebSocket endpoint. Rejects non-WebSocket requests with `404`, decodes JSON calls, resolves service paths such as `math/add`, executes Lua functions with `pcall(...)`, and writes JSON responses.
- `www/promise.html` - native browser client using `WebSocket`, Promises, and `async` / `await`.
- `www/index.html` - original jQuery-based browser client.
- `www/.preload` - simple startup print.

## Change Guidance

- Keep `service.lsp` focused on WebSocket RPC dispatch.
- Preserve the request/response envelope fields unless updating both browser clients: `rpcID`, `service`, `args`, `rsp`, and `err`.
- Be careful when exposing Lua functions. The example exposes `math` and `os` for demonstration; production code should expose only intentional service functions.
- Keep `promise.html` as the preferred modern client if adding or documenting new client behavior.
- Do not convert this example to SMQ; use `SMQ-examples/RPC` when the user wants RPC over SMQ.

## Run And Verify

Run from this directory:

```bash
cd AJAX-Over-WebSockets
mako -l::www
```

Verify by opening `promise.html`, confirming inputs become enabled after the WebSocket opens, testing add/subtract, and checking that direct HTTP access to `service.lsp` returns an error because it is a WebSocket endpoint.
