# AGENTS.md - File Server SSO

## Purpose

This example implements Microsoft Entra ID Single Sign-On with OpenID Connect and uses the resulting authentication to protect a BAS Web File Server/WebDAV endpoint. It also exposes session URLs for clients such as WebDAV tools that cannot complete browser SSO.

Use this example for Microsoft Entra ID SSO, OpenID Connect login flow, protected Web File Server setup, and session URL behavior.

## Read First

1. `README.md` - Azure setup, `mako.conf` settings, redirect URI requirements, and SSO flow.
2. `www/.preload` - SSO module initialization and Web File Server protection.
3. `www/.lua/ms-sso.lua` - reusable Microsoft SSO module.
4. `www/index.lsp` - browser login flow and secret-expiration handling.

Do not invent BAS authentication, request login, OpenID Connect, JWT, Web File Server, or WebDAV APIs.

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

- `www/.preload` - loads configuration from `mako.conf`, initializes SSO, creates an authenticator, and protects the Web File Server.
- `www/.lua/ms-sso.lua` - Microsoft Entra ID / OpenID Connect helper module.
- `www/index.lsp` - login UI, redirect start, token POST handling, `request:login(...)`, and expired-secret recovery UI.
- `www/logout.lsp` and `www/help.lsp` - Web File Manager integration pages.
- `www/assets/style.css` - page styling.

## Change Guidance

- Never commit real tenant IDs, client IDs, client secrets, or production redirect URIs.
- Redirect URI, HTTPS, trusted certificates, and browser origin rules are security-critical.
- For Xedge adaptation, move secrets and updated client secret persistence out of `mako.conf` and into the target's secure configuration/storage model.
- Preserve the distinction between browser SSO login and session URLs for WebDAV clients.
- If changing SSO error handling, keep the invalid/expired client secret codes handled by `index.lsp` unless replacing the flow deliberately.

## Run And Verify

Create `fs-sso/mako.conf` with the `openid` table described in `README.md`, then run:

```bash
cd fs-sso
mako -l::www
```

Verify login with Microsoft Entra ID, access to `/fs/`, logout behavior, and session URL access in a separate browser session.
