# AGENTS.md - require-test

## Purpose

This example demonstrates how `mako.createloader(io)` lets a Mako Server application use Lua `require(...)` and `io:dofile(...)` for modules stored inside the application IO tree.

## Read First

- `README.md` for the learning goal and run command.
- `www/.preload` for startup-time loader setup and module-loading examples.
- `www/index.lsp` for request-time `dofile(...)` and `require(...)` examples.
- `www/helloworld1.lua`, `www/.lua/helloworld2.lua`, and `www/.lua/subdir/helloworld3.lua` for module layout examples.

## Official Documentation (Source Of Truth)

Use the official Markdown documentation bundles for Mako Server, BAS Lua, LSP, and application IO behavior. Do not invent BAS, Mako, Lua loader, or IO APIs.

- BAS API bundle: https://realtimelogic.com/downloads/basapi.md
- BAS tutorials bundle: https://realtimelogic.com/downloads/tutorials.md
- Mako Server tutorials bundle: https://makoserver.net/download/tutorials.md

## Runtime And Compatibility

- This example is Mako-specific as written.
- Its purpose is specifically to demonstrate `mako.createloader(io)` and Mako module search-path behavior.
- Do not classify it as generic Xedge unless the loader code is rewritten for the target environment.

## Key Files

- `www/.preload`: calls `mako.createloader(io)` and demonstrates loading modules during app startup.
- `www/index.lsp`: repeats the loading examples from an LSP request context and shows how modules can receive `_ENV`.
- `www/helloworld1.lua`: module loaded directly from the app root.
- `www/.lua/helloworld2.lua`: module loaded from the hidden server-side `.lua` directory.
- `www/.lua/subdir/helloworld3.lua`: nested module loaded as `subdir.helloworld3`.

## Change Guidance

- Keep this example focused on module loading; avoid turning it into a general Lua packaging example.
- When adding modules, put reusable server-side code under `www/.lua/` and require it by module name.
- If a module needs to write to the current LSP response, pass `_ENV` explicitly instead of relying on globals.

## Verification

```bash
cd require-test
mako -l::www
```

Then open the printed URL and confirm the page prints output from all `dofile(...)` and `require(...)` variants.
