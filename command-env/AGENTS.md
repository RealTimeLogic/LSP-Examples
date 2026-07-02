# AGENTS.md - Command Environment

## Purpose

This directory contains two small examples that demonstrate the ephemeral BAS request/response command environment. The `include/` app shows shared header/footer rendering with `response:include(...)`; the `forward/` app shows how `response:forward(...)` transfers control to another LSP page during the same request.

Treat this as a container with two separate app roots.

## Read First

1. `README.md` - concept overview and run commands.
2. `include/` files when working on include behavior.
3. `forward/` files when working on forward behavior.

Do not invent request/response command environment, include, forward, or session APIs.

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

## Example Roots

- `include/` - demonstrates `response:include()` with `.header.lsp` and `.footer.lsp` shared by content pages.
- `forward/` - demonstrates `response:forward()` and how command environment variables behave through a forward chain.

## Key Files

- `include/index.lsp` - redirects to `page1.lsp`.
- `include/.header.lsp` and `include/.footer.lsp` - shared layout fragments.
- `include/page1.lsp` and `include/page2.lsp` - pages that include the shared layout.
- `forward/first.lsp`, `forward/.second.lsp`, and `forward/.third.lsp` - forward chain showing command environment and session behavior.

## Change Guidance

- Keep include and forward examples separate; they demonstrate different command environment behavior.
- Preserve the ordered reading flow in `forward/` when changing the example.
- If adding variables for demonstration, state whether they live in the command environment, session, or local scope.
- Do not add a single run command for `command-env/` itself; run the child app roots.

## Run And Verify

Run one app root at a time:

```bash
cd command-env
mako -l::include
mako -l::forward
```

Verify include pages render shared layout and forward pages trace the expected variable/session behavior.
