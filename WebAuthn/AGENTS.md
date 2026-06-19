# AGENTS.md - WebAuthn

## Purpose

This example provides a BAS WebAuthn module plus two example applications for passkey/FIDO2 authentication. Example 1 introduces registration and authentication, while Example 2 adds a more complete registration, email-verification, login, and protected file-server flow.

## Read First

- `README.md` for the tutorial flow, WebAuthn requirements, and active example selection.
- `WebAuthn.md` for the server-side WebAuthn module API.
- `mako.conf` for the active Mako example and supporting configuration.
- `WebAuthnModule/.lua/webauthn.lua` for the reusable server-side module.
- `example1/.preload` and `example1/index.html` for the introductory flow.
- `example2/.preload`, `example2/.login.lsp`, `.RegEmail`, and `registered.shtml` for the complete flow.

## Official Documentation (Source Of Truth)

Use the official Markdown documentation bundles for BAS, Mako Server, Xedge deployment, authentication, JSON/CBOR handling, LSP, and filesystem APIs. Do not invent BAS, Lua, LSP, authenticator, or WebAuthn module APIs.

- BAS API bundle: https://realtimelogic.com/downloads/basapi.md
- BAS tutorials bundle: https://realtimelogic.com/downloads/tutorials.md
- Mako Server tutorials bundle: https://makoserver.net/download/tutorials.md

For browser/client semantics, also consult the WebAuthn specification and SimpleWebAuthn browser documentation referenced by `README.md`.

## Runtime And Compatibility

- The documented local workflow uses Mako Server and `mako.conf`; run `mako` from the `WebAuthn` directory.
- The directory also contains Xedge `.config` files and Xedge-aware code paths, but Xedge deployment requires correct HTTPS, trusted certificates, origin settings, storage, and email configuration.
- WebAuthn normally requires trusted HTTPS and a DNS name. `http://localhost` is the main browser exception for local testing.

## Key Files

- `mako.conf`: selects `activeExample` and provides Mako-specific settings such as SMTP support.
- `.config`, `example1/.config`, `example2/.config`, `WebAuthnModule/.config`: Xedge app metadata.
- `WebAuthnModule/.lua/webauthn.lua`: reusable server-side WebAuthn implementation.
- `WebAuthnModule/.preload`: makes the module app available to examples.
- `example1/.preload`: creates a WebAuthn instance, persists the CBOR-encoded user database, and implements registration/authentication callbacks.
- `example1/index.html`: SimpleWebAuthn browser client for the introductory demo.
- `example2/.preload`: adds quarantined registration, optional registration email, BAS form authenticator integration, and Web File Server protection.
- `example2/.login.lsp`: passkey login and registration UI.

## Change Guidance

- Keep the reusable module in `WebAuthnModule/`; put example-specific policy in `example1/` or `example2/`.
- Do not weaken WebAuthn origin, TLS, or hostname requirements to make a demo easier.
- If changing usernames, keep normalization consistent between browser code and server-side database keys.
- When modifying Example 2, preserve the difference between registration, activation, authentication, and BAS login.
- If adding external browser libraries, review CSP/deployment constraints for the selected target.

## Verification

For the Mako workflow:

```bash
cd WebAuthn
mako
```

Then verify:

- `mako.conf` selects the intended `activeExample`.
- Browser registration and authentication succeed on `localhost` or a trusted HTTPS origin.
- Example 2 either sends registration email or prints a registration URL that can be copied manually.
- Protected Example 2 pages are inaccessible until WebAuthn login succeeds.
