# AGENTS.md - upload

## Purpose

This directory contains two file-upload examples for BAS applications: a simpler blocking upload flow and a more advanced asynchronous upload flow. Both examples present a firmware-upload style browser UI with form and drag-and-drop support.

## Read First

- `README.md` for the directory overview and variant choice.
- `blocking/README.md` before changing the blocking example.
- `asynchronous/README.md` before changing the asynchronous example.
- The selected variant's `www/.preload`, `www/index.lsp`, and `www/upload.js`.

## Official Documentation (Source Of Truth)

Use the official Markdown documentation bundles for BAS request handling, upload handling, IO objects, LSP parsing, threads, Mako Server, and Xedge deployment. Do not invent BAS, Lua, LSP, upload, or IO APIs.

- BAS API bundle: https://realtimelogic.com/downloads/basapi.md
- BAS tutorials bundle: https://realtimelogic.com/downloads/tutorials.md
- Mako Server tutorials bundle: https://makoserver.net/download/tutorials.md

## Runtime And Compatibility

- Each upload variant is a separate app with its own `www` directory.
- The examples run locally with Mako using the commands in each variant README.
- The patterns can be adapted for Xedge when the upload storage IO and writable paths are changed to fit the target.
- The asynchronous example expects a suitable `home` IO, and the code comments note that it was designed to run with the web file server environment.

## Variants

- `blocking/`: simpler request-driven upload example; preferred starting point for most projects.
- `asynchronous/`: uses `ba.create.upload()` and deferred response handling for higher upload concurrency.

## Key Files

- `blocking/www/.preload`: creates the upload IO and blocking upload handler support.
- `blocking/www/index.lsp`: serves the upload UI and handles blocking upload requests.
- `blocking/www/upload.js`: browser drag-and-drop upload logic.
- `asynchronous/www/.preload`: creates the asynchronous upload object, builds a response environment, parses/runs `.managezip.lsp`, and delegates response work to a thread.
- `asynchronous/www/index.lsp`: forwards non-`GET` requests to `app.upload(request)` and serves the upload UI.
- `asynchronous/www/.managezip.lsp`: post-upload ZIP-management logic.

## Change Guidance

- Start with `blocking/` unless the user explicitly needs high upload concurrency.
- Keep upload storage paths configurable and target-specific; do not assume all deployments have the same writable IO.
- Keep server-side validation of uploaded file type and size; browser checks in `upload.js` are convenience checks only.
- If adding external assets or scripts, update the selected app's CSP or deployment notes as applicable.

## Verification

Blocking variant:

```bash
cd upload/blocking
mako -l::www
```

Asynchronous variant:

```bash
cd upload/asynchronous
mako -l::www
```

Verify form upload, drag-and-drop upload, progress UI, ZIP validation, and server-side storage behavior for the selected variant.
