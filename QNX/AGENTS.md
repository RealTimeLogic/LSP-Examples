# AGENTS.md - QNX

## Purpose

This directory contains QNX-specific BAS examples. The current example is `PPS`, a reusable Lua bridge that maps QNX Persistent Publish Subscribe (PPS) messages to SMQ topics so browser or other SMQ clients can interact with PPS-backed services.

## Read First

- `PPS/README.md` for the bridge behavior and usage examples.
- `PPS/www/.lua/pps.lua` for PPS parsing, PPS encoding, SMQ broker creation, topic subscription, and last-value handling.

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

Use the official Markdown documentation bundles for BAS, Lua, SMQ, pipes, sockets, and server APIs. Do not invent BAS, Lua, SMQ, or QNX integration APIs.

- BAS API bundle: https://realtimelogic.com/downloads/basapi.md
- BAS tutorials bundle: https://realtimelogic.com/downloads/tutorials.md
- Mako Server tutorials bundle: https://makoserver.net/download/tutorials.md

For PPS semantics, consult QNX PPS documentation in addition to the BAS bundles.

## Runtime And Compatibility

- This is a QNX/BAS integration module, not a generic Mako or Xedge app.
- It depends on QNX PPS paths and `ba.pipe.open(...)` access to the QNX PPS service.
- Do not replace PPS behavior with generic file or socket code unless the user explicitly asks for a non-QNX adaptation.

## Key Files

- `PPS/README.md`: usage, browser client examples, and troubleshooting notes.
- `PPS/www/.lua/pps.lua`: exports `require"pps".create(op)`, creates an SMQ broker, opens PPS pipes, converts PPS key/value text to Lua tables, publishes to SMQ, and writes SMQ-originated JSON back to PPS.

## Change Guidance

- Preserve the conversion boundary: PPS text <-> Lua table <-> SMQ JSON-compatible messages.
- Keep topic names aligned with actual QNX PPS paths such as `/pps/my-service`.
- When adding browser examples, use the SMQ APIs documented in `basapi.md` and keep PPS access server-side.
- If changing hardware or platform-specific paths, ask the user which QNX PPS paths are available on the target system.

## Verification

There is no standalone top-level run command. Integrate the module into a BAS application on QNX, then verify:

- `require"pps".create(op)` returns both PPS and SMQ objects.
- `pps:subscribe("/pps/...")` opens the target PPS object.
- PPS-to-SMQ messages publish JSON-compatible values.
- SMQ-to-PPS JSON messages are encoded back to PPS key/value text.
