# AGENTS.md - RADIUS

## Purpose

This example shows how a BAS web application can authenticate users through a RADIUS server. It combines a small Lua RADIUS client with BAS authentication callbacks and form/basic authentication handling.

## Read First

- `README.md` for FreeRADIUS setup, test credentials, and run commands.
- `www/.preload` for the authentication callback, authenticator setup, and directory protection.
- `www/.lua/radius.lua` for the RADIUS Access-Request packet implementation.
- `www/.login/form.lsp` and `www/.login/failed.lsp` for the login UI.

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

Use the official Markdown documentation bundles for BAS authentication, sockets, crypto helpers, LSP, and Mako/Xedge deployment. Do not invent BAS, Lua, authentication, socket, or crypto APIs.

- BAS API bundle: https://realtimelogic.com/downloads/basapi.md
- BAS tutorials bundle: https://realtimelogic.com/downloads/tutorials.md
- Mako Server tutorials bundle: https://makoserver.net/download/tutorials.md

## Runtime And Compatibility

- The example runs with Mako using `mako -l::www`.
- The design can be adapted for Xedge when the target can reach the RADIUS server and the app loader/deployment details are adjusted for that target.
- The demo assumes a local RADIUS server at `127.0.0.1:1812` with shared secret `myradiussecret`.

## Key Files

- `www/.preload`: configures the RADIUS client, implements the BAS password callback, creates the authenticator, and protects the app directory.
- `www/.lua/radius.lua`: builds RADIUS AVPs, obfuscates passwords with MD5 according to the RADIUS protocol, sends UDP requests, and validates responses.
- `www/.login/`: form-authentication pages.
- `www/public/`: static assets used by the login flow.

## Change Guidance

- Treat the shared secret as configuration, not as page content.
- Do not log real passwords or shared secrets. The demo has trace output for learning; remove sensitive traces for production.
- Keep Digest authentication disabled unless implementing the necessary RADIUS-compatible flow.
- If changing RADIUS server settings, update `radiusServerIP`, `radiusServerPort`, and `sharedSecret` in `www/.preload`.

## Verification

```bash
cd RADIUS
mako -l::www
```

With FreeRADIUS configured as described in `README.md`, verify:

- Browser form login succeeds with `testuser` / `testpass`.
- Failed credentials route to the failure page.
- HTTP Basic auth works with `curl -i -u "testuser:testpass" http://localhost` when Mako is listening on port 80.
