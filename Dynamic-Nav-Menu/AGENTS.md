# AGENTS.md - Dynamic Navigation Menu

## Purpose

This example is a multi-page LSP application with a shared dynamic navigation header, custom 404 handling, and form-based authentication backed by a JSON user database with HA1 password hashes.

Use it when the task involves shared LSP layout, active navigation, JSON-backed users, hashed form login, or small protected multi-page apps.

## Read First

1. `README.md` - tutorial overview, credentials, and file map.
2. `www/.preload` - authenticator, JSON user database, and 404 setup.
3. `www/.header.lsp` - shared navigation/menu rendering.
4. `www/.login-form.lsp` - form login flow.

Do not invent BAS authentication, JSON user database, response forwarding, or LSP APIs.

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

- `www/.preload` - installs a sibling 404 handler, builds the JSON user database, creates a form authenticator, and applies it to `dir`.
- `www/.header.lsp` - shared page header and active navigation menu.
- `www/.login-form.lsp` - form-based login page for the authenticator.
- `www/.404.lsp` - custom not-found page.
- `www/index.lsp`, `network.lsp`, `security.lsp`, `users.lsp`, `admin.lsp` - main protected pages.
- `www/public/` - unauthenticated CSS/JS/assets required by the login flow.

## Change Guidance

- Keep the authenticator realm synchronized with stored HA1 hashes.
- If users or passwords change, update the JSON user database and hash generation logic together.
- Public login assets must remain under `www/public/` so unauthenticated users can load them.
- New protected pages should include the shared header and footer pattern.
- If changing navigation, update shared header logic rather than duplicating menus per page.

## Run And Verify

```bash
cd Dynamic-Nav-Menu
mako -l::www
```

Log in with `admin` / `password`, verify menu highlighting, test a missing URL for the 404 flow, and check the `ADMIN` tab.
