# AGENTS.md - anti-session

## Purpose

This example demonstrates a stateless multi-page form workflow that avoids the server-side session object. The browser carries encrypted JSON state in a hidden form field, and the server decrypts, updates, and re-encrypts that state on each POST.

## Read First

- `README.md` for the complete workflow and limitations.
- `www/.preload` for the AES key, encryption/decryption helpers, HTML escaping, and input trimming.
- `www/index.lsp` for creating the initial encrypted state.
- `www/name.lsp`, `www/food.lsp`, and `www/summary.lsp` for the form flow.
- `www/header.shtml`, `www/footer.shtml`, and `www/style.css` for the shared page layout.

## Official Documentation (Source Of Truth)

Use the official Markdown documentation bundles for BAS Lua, LSP, AES helpers, JSON, request/response handling, Mako Server, and Xedge deployment. Do not invent BAS, Lua, LSP, AES, or JSON APIs.

- BAS API bundle: https://realtimelogic.com/downloads/basapi.md
- BAS tutorials bundle: https://realtimelogic.com/downloads/tutorials.md
- Mako Server tutorials bundle: https://makoserver.net/download/tutorials.md

## Runtime And Compatibility

- The documented local run path uses Mako Server with `mako -l::www`.
- The pattern is portable to Xedge because it uses BAS/LSP APIs and no Mako-only runtime calls.
- Existing encrypted form state becomes invalid when the app restarts because `.preload` creates a new AES key.

## Key Files

- `www/.preload`: creates the AES key and defines `encodeState`, `decodeState`, `escapeHtml`, and `trim` in app scope.
- `www/index.lsp`: creates the initial state with the current server time and posts it to `name.lsp`.
- `www/name.lsp`: validates encrypted state and asks for the user's name.
- `www/food.lsp`: decrypts state, adds the name, re-encrypts state, and asks for favorite food.
- `www/summary.lsp`: decrypts the final state and renders the collected values.
- `www/header.shtml` and `www/footer.shtml`: shared shell used by each LSP page.
- `www/style.css`: local styling for the example.

## Change Guidance

- Keep encrypted state small; hidden form fields are not a database.
- Always HTML-escape decrypted or submitted values before rendering.
- Validate required form fields before re-encrypting state for the next page.
- If adding expiry checks, use the existing `started` timestamp as the natural place to enforce age.
- If persistent encrypted state across app restarts is required, replace the generated AES key with a managed secret and document the security tradeoff.

## Verification

```bash
cd anti-session
mako -l::www
```

Then verify:

- The initial page posts to `name.lsp` with a hidden encrypted `state` field.
- The form flow reaches `summary.lsp` and displays start time, name, and favorite food.
- Missing or invalid state shows the error path and a start-over link.
