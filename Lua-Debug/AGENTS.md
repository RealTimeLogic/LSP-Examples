# AGENTS.md - Lua Debug

## Purpose

This example supports the Lua and LSP debugging tutorial using Mako Server, Visual Studio Code, the Lua Debug extension, and the BAS debug monitor. It includes a primary debug target app and a helper FileServer app for remote debugging/source mapping.

As written, this is Mako Server focused. It can be adapted by AI for Xedge-style workflows, but that requires changing debug monitor startup, app loading, restart assumptions, and source mapping behavior.

## Read First

1. `README.md` - required debugger setup and workflow.
2. `www/.preload` - debug monitor startup and module loading.
3. `www/.vscode/launch.json` - VS Code debug client configuration.
4. `www/index.lsp` - LSP debug target.
5. `www/.lua/Markow-Chain.lua` - Lua module used for stepping and breakpoints.
6. `FileServer/` files when working on remote debugging support.

Do not invent Mako debug monitor, VS Code launch, LSP, module loading, or restart APIs.

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

- `www/.preload` - loads the debug monitor and the Markow Chain module.
- `www/.vscode/launch.json` - debugger connection and source mapping configuration.
- `www/index.lsp` - browser-triggered LSP page for debugging.
- `www/.lua/Markow-Chain.lua` - Lua module for stepping/breakpoint practice.
- `FileServer/.preload` and `FileServer/index.lsp` - helper app for remote debugging and generated launch configuration.

## Change Guidance

- Preserve Mako Server debugger workflow unless the user explicitly asks for Xedge adaptation.
- If adapting to Xedge, state which Mako assumptions are being replaced: app loading, debug monitor connection, source mappings, and restart behavior.
- Keep `.preload`, `.lsp`, and `.config` file association guidance aligned with README instructions.
- Avoid editing generated or environment-specific `launch.json` paths without confirming the user's debugger location.

## Run And Verify

```bash
cd Lua-Debug
mako -l::www
```

Verify Mako prints that the debug monitor is waiting on port `4711`, open `Lua-Debug/www` in VS Code, start the debugger, and confirm it halts in `.preload` or the LSP page as described in the README.
