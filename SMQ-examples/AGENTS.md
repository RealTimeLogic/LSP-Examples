# AGENTS.md - SMQ-examples

## Purpose

This directory is an index of SMQ examples. The subdirectories demonstrate browser-to-server, browser-to-browser, browser-to-device, RPC, game, IoT, and clustering patterns built on Simple Message Queue (SMQ).

## Read First

- `README.md` for the directory index and subexample selection.
- The README in the specific subdirectory being modified.
- The `.preload`, `smq.lsp`, Lua modules, and browser JavaScript files in that subdirectory.

Recommended starting points:

- `one2one/README.md` for basic direct browser/server messaging.
- `RPC/README.md` for request/response calls over SMQ.
- `IoT/README.md` for chat and LED-control tutorial examples.
- `LightSwitch-And-LightBulb-App/README.md` for a simple browser switch/bulb interaction.
- `BlobArena/README.md` for AI-generated multiplayer game examples.
- `cluster/README.md` for the Mako-specific local cluster experiment.

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

Use the official Markdown documentation bundles for native SMQ, Lua, LSP, JavaScript, Mako Server, and Xedge behavior. Do not invent SMQ publish/subscribe APIs or message-addressing rules.

- BAS API bundle: https://realtimelogic.com/downloads/basapi.md
- BAS tutorials bundle: https://realtimelogic.com/downloads/tutorials.md
- Mako Server tutorials bundle: https://makoserver.net/download/tutorials.md

## Detailed SMQ Skill

For any non-trivial SMQ code change, read the centralized SMQ AI skill before editing broker setup, browser clients, topic names, publish/subscribe flow, direct messaging, reconnect behavior, or cleanup logic:

- https://realtimelogic.com/downloads/ai-skills/SMQ-Skill.md

This local AGENTS.md explains the structure of the examples in this directory. The centralized SMQ skill provides reusable SMQ-specific implementation guidance for this and other repositories.

## Runtime And Compatibility

- Most subexamples are portable between Mako and Xedge when the SMQ endpoint is available and paths are adapted for the target.
- `BlobArena` includes Mako and Xedge/Xedge32 packaging instructions for the selected `codex` or `gemini` variant.
- `cluster` is Mako-specific as written because it creates local multi-node configuration and expects multiple local Mako instances.
- Do not apply cluster assumptions to the simpler SMQ browser examples.

## Native SMQ Guidance

Server-side Lua publish signatures are:

```lua
smq:publish(data, "topic")
smq:publish(data, ptid, "subtopic")
```

Use the exact native API documented in `basapi.md`. If a subexample has its own wrapper, document that wrapper separately from the underlying SMQ API.

## Key Subdirectories

- `one2one/`: direct browser/server SMQ messaging.
- `RPC/`: Promise-style browser RPC over SMQ with server-side Lua dispatch.
- `IoT/`: chat and LED-control tutorial bundle.
- `LightSwitch-And-LightBulb-App/`: switch and bulb pages using SMQ.
- `BlobArena/`: AI-generated multiplayer Canvas game variants using SMQ.
- `cluster/`: local Mako cluster simulation; follow `cluster/README.pdf` for setup.

## Change Guidance

- Modify only the selected subexample unless the user explicitly requests cross-example parity.
- Keep SMQ endpoint paths aligned between browser code and server-side `smq.lsp` or broker setup.
- When porting to Xedge, package the selected app/subdirectory only and adjust endpoint paths, not the whole `SMQ-examples` tree.
- For browser code, prefer native browser APIs unless an existing subexample already uses a library.

## Verification

There is no single run command for the whole directory. Run the selected subexample, for example:

```bash
cd SMQ-examples/one2one
mako -l::www
```

or:

```bash
cd SMQ-examples/RPC
mako -l::www
```

For UI examples, open multiple browser windows when needed to verify publish/subscribe behavior.
