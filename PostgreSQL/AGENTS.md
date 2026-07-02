# AGENTS.md - PostgreSQL

## Purpose

This example demonstrates a persistent PostgreSQL connection for a Mako Server application. It keeps one PostgreSQL connection helper alive in application scope and runs database work on a BAS thread so LSP pages do not hold request objects across thread boundaries.

## Read First

- `README.md` for setup, ElephantSQL credentials, and the intended workflow.
- `mako.conf` for the database connection table `cinfo`.
- `www/.preload` for startup, `pgsql.so` validation, loader setup, and shared `pg` creation.
- `www/.lua/pg.lua` for connection lifecycle, reconnect behavior, and threaded execution.
- `www/index.lsp` for deferred-response handling and SQL operations.

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

Use the official Markdown documentation bundles for BAS, Lua Server Pages, Mako Server startup, threading, and database-related APIs. Do not invent BAS, Mako, Lua, LSP, or threading APIs.

- BAS API bundle: https://realtimelogic.com/downloads/basapi.md
- BAS tutorials bundle: https://realtimelogic.com/downloads/tutorials.md
- Mako Server tutorials bundle: https://makoserver.net/download/tutorials.md

## Runtime And Compatibility

- This example is Mako-specific as written.
- It depends on local `mako.conf`, `mako.createloader(io)`, and a host-compiled native `pgsql.so` binding.
- Do not mark this example as Xedge-compatible unless the native PostgreSQL binding, configuration loading, and deployment model have been redesigned for that target.

## Key Files

- `mako.conf`: Mako app configuration and PostgreSQL connection details.
- `www/.preload`: validates the PostgreSQL binding, loads configuration, creates the persistent `pg` helper, and closes it in `onunload()`.
- `www/.lua/pg.lua`: wraps `pgsql.so`, maintains connection state, pings/resets the connection, and queues work on a BAS thread.
- `www/index.lsp`: demonstrates `response:deferred()`, safe response writes from a worker thread, table creation, inserts, and listing rows.

## Change Guidance

- Keep request/response objects out of background threads unless the response has been explicitly converted with `response:deferred()`.
- Use parameterized SQL such as `conn:execParams(...)` for user-provided values.
- Do not log real database credentials from `mako.conf` in production examples.
- If adding new database operations, put reusable connection behavior in `www/.lua/pg.lua` and page-specific rendering in `www/index.lsp` or a new LSP page.

## Verification

From this directory:

```bash
mako
```

Then verify:

- Mako prints `DB connected: yes`.
- The browser can submit the form and see inserted rows.
- Stopping the app calls `onunload()` and closes the database connection.
