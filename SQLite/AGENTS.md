# AGENTS.md - SQLite

## Purpose

This directory indexes three SQLite examples for BAS applications: a basic Lua SQLite tutorial, a small URL-to-database wiki, and a shared-connection example focused on locking and connection management.

## Read First

- `README.md` for the directory overview and subexample selection.
- `Tutorial/README.md` for the basic form-driven SQLite tutorial.
- `Wiki/README.md` for URL-to-database mapping.
- `Shared-Connection/README.md` for shared connection and locking behavior.
- The `.preload` and LSP files in the chosen subdirectory.

## Official Documentation (Source Of Truth)

Use the official Markdown documentation bundles for BAS, Lua, LSP, SQLite integration, Mako Server, and Xedge deployment. Do not invent BAS, Lua, LSP, database, or storage APIs.

- BAS API bundle: https://realtimelogic.com/downloads/basapi.md
- BAS tutorials bundle: https://realtimelogic.com/downloads/tutorials.md
- Mako Server tutorials bundle: https://makoserver.net/download/tutorials.md

## Runtime And Compatibility

- Each subdirectory is its own example app and has its own run command.
- The patterns are usable with Mako and can be adapted for Xedge when SQLite support and writable persistent storage are available.
- Storage paths and persistence behavior must be reviewed for the target deployment.

## Key Subdirectories

- `Tutorial/`: basic form-driven SQLite workflow using `www/.preload`, `www/index.lsp`, and `www/style.css`.
- `Wiki/`: small wiki engine that maps URLs to database-backed content using startup logic, edit pages, and an index page.
- `Shared-Connection/`: shared SQLite access example with manual and automatic insert modes for observing locking behavior.

## Change Guidance

- Modify only the selected subexample unless the user asks for parity across all SQLite examples.
- Keep database initialization in `.preload` and request-specific behavior in LSP pages unless the subexample already has another pattern.
- For Xedge, confirm the target has SQLite support and a suitable writable storage location before changing paths.
- Do not present these examples as production-ready database applications; they are focused teaching examples.

## Verification

Run the selected subexample:

```bash
cd SQLite/Tutorial
mako -l::www
```

```bash
cd SQLite/Wiki
mako -l::www
```

```bash
cd SQLite/Shared-Connection
mako -l::www
```

Verify database file creation/update behavior and the specific browser flow described in the selected README.
