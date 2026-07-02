# AGENTS.md - MySQL And Redis Drivers

## Purpose

This example packages OpenResty-style MySQL and Redis drivers adapted for BAS socket/cosocket behavior. It includes a reusable ZIP-style driver package under `MySQL/` and LSP test pages under `www/`.

Use it for MySQL/Redis driver packaging, OpenResty compatibility, BAS cosocket usage, and persistent MySQL connection patterns.

## Read First

1. `README.md` - package layout, Docker test setup, and driver behavior.
2. `MySQL/.lua/resty/mysql.lua` - MySQL driver and BAS-specific persistent connection helpers.
3. `MySQL/.lua/resty/redis.lua` - Redis driver.
4. `www/MySQL.lsp` and `www/Redis.lsp` - test pages.
5. `MySQL/.preload` and `www/.preload` - app/package startup behavior.

Do not invent BAS sockets, cosocket, OpenResty compatibility, MySQL, or Redis APIs.

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

## Key Files

- `MySQL/` - reusable package containing `.config`, `.preload`, and `.lua/resty/*` modules.
- `www/MySQL.lsp` - MySQL blocking and `ba.socket.event(...)` tests.
- `www/Redis.lsp` - Redis set/get and pipeline tests.
- `www/.preload` - startup message for test pages.

## Change Guidance

- Preserve hidden files/directories when packaging; `.config`, `.preload`, and `.lua` are required.
- Keep OpenResty-compatible `require "resty.mysql"` and `require "resty.redis"` paths intact.
- If changing connection settings, update README setup steps and test pages.
- Use `ba.socket.event(...)` outside plain LSP blocking contexts when demonstrating cosocket behavior.
- Do not claim connection pooling is implemented; the compatibility layer closes pooled sockets.

## Run And Verify

Package the driver ZIP:

```bash
cd MysqlAndRedis/MySQL
zip -D -q -u -r -9 ../MySQL.zip .
```

Run the package and pages:

```bash
cd ..
mako -l::MySQL.zip -l::www
```

Start local MySQL and Redis as described in `README.md`, then open `/MySQL.lsp` and `/Redis.lsp`.
