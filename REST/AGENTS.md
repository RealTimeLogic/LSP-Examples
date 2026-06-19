# AGENTS.md - REST

## Purpose

This example implements a minimal REST-style router in Lua for BAS applications and demonstrates it with an in-memory `/api/users` service.

## Read First

- `README.md` for the tutorial context, endpoint list, and test command.
- `REST-API.md` for the router API and matching semantics.
- `www/.lua/rest.lua` for the reusable router implementation.
- `www/.preload` for the example `/api/users` application and route definitions.
- `TestApi.py` for a simple external client that exercises the API.

## Official Documentation (Source Of Truth)

Use the official Markdown documentation bundles for BAS virtual file system directories, request/response handling, JSON, and Mako/Xedge deployment. Do not invent BAS, Lua, LSP, VFS, or HTTP APIs.

- BAS API bundle: https://realtimelogic.com/downloads/basapi.md
- BAS tutorials bundle: https://realtimelogic.com/downloads/tutorials.md
- Mako Server tutorials bundle: https://makoserver.net/download/tutorials.md

## Runtime And Compatibility

- The example runs locally with Mako using `mako -l::www`.
- The router pattern is portable to Xedge when packaged with the app and mounted in the target application.
- Storage is in memory only; restarting the app clears users.

## Key Files

- `www/.lua/rest.lua`: creates a router with exact and greedy-wildcard route matching and installs it as a BAS directory function.
- `www/.preload`: creates the router, defines `/api/users` endpoints, sends JSON responses, parses JSON request bodies, and unlinks the router in `onunload()`.
- `REST-API.md`: developer-facing API reference for `route(...)`, `install(...)`, and matching rules.
- `TestApi.py`: client test script that assumes the API is reachable at `http://localhost/api/users`.

## Change Guidance

- Keep `www/.lua/rest.lua` reusable and avoid mixing app-specific user logic into the router module.
- Add new service routes in `www/.preload` or another app-specific module.
- Return JSON with appropriate HTTP status codes and validate request bodies before mutating state.
- If adding persistent storage, isolate that code from the router so the routing API remains small.

## Verification

```bash
cd REST
mako -l::www
```

For the included Python test script, run Mako on port 80 as described in `README.md`, then run:

```bash
python TestApi.py
```

Verify the main endpoints: `GET`, `POST`, `GET /{id}`, `PUT /{id}`, and `DELETE /{id}` under `/api/users`.
