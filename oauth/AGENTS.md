# AGENTS.md - OAuth 2.0 Example

## Purpose

This directory contains a GitHub OAuth 2.0 client example converted from PHP to LSP. It demonstrates the browser redirect flow, callback handling, state validation, session storage, token exchange, and GitHub API calls.

As written, this example is Mako Server focused because it uses `mako.sharkclient()` and stores client credentials directly in the LSP file. It needs security and configuration changes before production or Xedge use.

## Read First

1. `README.md` - run command and OAuth setup notes.
2. `sample-oauth2-client/github.lsp` - complete OAuth flow.

Do not invent OAuth, session, HTTP client, SharkSSL, or LSP APIs.

## Official Documentation (Source Of Truth)

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
