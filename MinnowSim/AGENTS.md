# AGENTS.md - MinnowSim

## Purpose

This example is the server-side Lua/WebSocket simulator for the Minnow tutorial SPA. It runs together with the separate `MinnowServer` browser app and simulates device behavior such as GPIO, LED state, temperature updates, WebSocket JSON messages, AJAX-style calls over WebSocket, authentication, and firmware upload frames.

Use this example when working on the simulated device/backend side of the Minnow SPA tutorial.

## Read First

1. `README.md` - two-repository run model and default credentials.
2. `www/.preload` - simulated device state, WebSocket client management, handlers, timers, and cleanup.
3. `www/index.lsp` - WebSocket upgrade endpoint and redirect to `/minnow/`.

Do not invent BAS WebSocket, JSONS, session, GPIO simulation, or file upload APIs.

## Official Documentation (Source Of Truth)

This `AGENTS.md` may be copied standalone into other work directories. Treat the
local paths below as relative to the directory containing this file.

Before using any public BAS, Mako, Xedge, Xedge32, OPC UA, or AI-skill URL:

1. Look for a local cached copy under `./.agents/reference/rtl/`.
2. If the file is missing and network access is available, download it from the
   listed source URL and save it there before using it.
3. Record the source URL and download date in `./.agents/reference/rtl/manifest.md`
   or in a short header at the top of the cached file.
4. Use the local cached copy for normal work.
5. Re-fetch the public URL only when the user asks for current/latest guidance,
   the cached file is missing, or the cached file conflicts with observed runtime
   behavior.

For fully offline use, copy this `AGENTS.md` together with the
`./.agents/reference/rtl/` directory. If only `AGENTS.md` is copied into an
offline directory, the cache cannot be populated until network access is
available.

- **BAS documentation bundle (`basapi.md`)**  
  https://realtimelogic.com/downloads/basapi.md

- **BAS tutorials bundle (`tutorials.md`)**  
  https://realtimelogic.com/downloads/tutorials.md

- **Mako Server tutorials bundle (`tutorials.md`)**  
  https://makoserver.net/download/tutorials.md

Reference priority:

1. `basapi.md` for API syntax, signatures, and behavior.
2. `tutorials.md` for architecture, security, deployment, and tutorial context.
3. If tutorial guidance conflicts with API details, trust the API reference.


## Required Companion Repository

`MinnowSim` is not enough by itself. The browser SPA lives in the separate `MinnowServer` repository:

```bash
git clone https://github.com/RealTimeLogic/MinnowServer
```

Before running or debugging this example, check whether `MinnowServer` exists as a sibling of `LSP-Examples` or ask the user where it is checked out. If it is missing and network access is allowed, clone it into the same parent directory as `LSP-Examples`.

The required Mako setup mounts:

- `MinnowServer/www` as `/minnow/`;
- `LSP-Examples/MinnowSim/www` as `/`.

## Key Files

- `www/.preload` - app startup and all simulated device behavior.
- `www/index.lsp` - hands WebSocket requests to `app.newClient`; redirects normal browser requests to `/minnow/`.

## Change Guidance

- Keep the split clear: `MinnowSim` is the backend/device simulator; `MinnowServer` provides the browser SPA.
- Preserve the two-app Mako load command unless the user changes repository layout.
- If changing WebSocket message names, update the SPA in `MinnowServer` too.
- Treat `credentials.json` and `FIRMWARE.bin` as runtime artifacts stored in app storage.
- When adapting to real Xedge32 hardware, replace simulated GPIO with actual device APIs and confirm pins/hardware behavior.

## Run And Verify

From the parent directory containing both repositories:

```bash
mako -lminnow::MinnowServer/www -l::LSP-Examples/MinnowSim/www
```

From inside `LSP-Examples` when `MinnowServer` is a sibling:

```bash
mako -lminnow::../MinnowServer/www -l::MinnowSim/www
```

Open `/minnow/`, log in with `root` / `password`, and verify LED, temperature, AJAX, and upload flows.
