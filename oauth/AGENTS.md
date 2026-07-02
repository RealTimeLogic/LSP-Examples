# AGENTS.md - OAuth 2.0 Example

## Purpose

This directory contains a GitHub OAuth 2.0 client example converted from PHP to LSP. It demonstrates the browser redirect flow, callback handling, state validation, session storage, token exchange, and GitHub API calls.

As written, this example is Mako Server focused because it uses `mako.sharkclient()` and stores client credentials directly in the LSP file. It needs security and configuration changes before production or Xedge use.

## Read First

1. `README.md` - run command and OAuth setup notes.
2. `sample-oauth2-client/github.lsp` - complete OAuth flow.

Do not invent OAuth, session, HTTP client, SharkSSL, or LSP APIs.

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

- `sample-oauth2-client/github.lsp` - GitHub OAuth 2.0 client flow, including authorization redirect, state check, token exchange, session token storage, GitHub API calls, and logout.

## Change Guidance

- Never commit real GitHub OAuth client secrets.
- Move `githubClientID` and `githubClientSecret` out of the LSP file before non-demo use.
- Preserve state generation and validation; it protects the OAuth callback flow.
- If adapting to Xedge, replace `mako.sharkclient()` and file-embedded credentials with target-appropriate HTTP/TLS client and secure configuration.
- Confirm callback URL/origin settings in the GitHub OAuth application before debugging code.

## Run And Verify

Configure GitHub OAuth app credentials in `sample-oauth2-client/github.lsp`, then run:

```bash
cd oauth
mako -l::sample-oauth2-client
```

Open the printed URL, start login, complete GitHub authorization, and verify repository listing works.
