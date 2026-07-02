# AGENTS.md - LSP Examples

## Purpose

This repository contains independent Barracuda App Server (BAS) examples. BAS is
the embedded web/application server C code library used by Mako Server, Xedge, and Xedge32. LSP
means Lua Server Pages.

Use this file as the repository-level baseline. If the selected example has its
own `AGENTS.md`, that file is more specific and must be read before editing.

## First Steps

- Identify the exact example or subexample before changing files.
- Read that example's `README.md` first; it is the run and verification contract.
- Read any local `AGENTS.md`, design note, or skill file named by the README or
  local AGENTS file.
- Modify only the selected example unless the user explicitly asks for
  cross-example parity.
- Keep the common example shape when adding or moving app files: root
  `README.md`, runnable app files under `www/` or the variant directory named by
  the local README.

## Source Of Truth

Do not invent BAS, Lua, LSP, SMQ, Mako, Xedge, or Xedge32 APIs. Use the official
documentation for exact names, signatures, and behavior:

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

| Reference | Local copy | Source URL |
| --- | --- | --- |
| BAS API bundle | `./.agents/reference/rtl/basapi.md` | `https://realtimelogic.com/downloads/basapi.md` |
| BAS tutorials bundle | `./.agents/reference/rtl/tutorials.md` | `https://realtimelogic.com/downloads/tutorials.md` |
| Mako Server tutorials | `./.agents/reference/rtl/mako-tutorials.md` | `https://makoserver.net/download/tutorials.md` |
| Xedge32 and ESP32 API reference | `./.agents/reference/rtl/esp32api.md` | `https://realtimelogic.com/downloads/esp32api.md` |
| OPC UA API reference | `./.agents/reference/rtl/opcuaapi.md` | `https://realtimelogic.com/downloads/opcuaapi.md` |

Reference priority:

1. `basapi.md` for BAS API syntax, signatures, and behavior.
2. `tutorials.md` for BAS architecture, patterns, examples, and security guidance.
3. Mako tutorials for Mako-specific packaging, deployment, or server behavior.
4. `esp32api.md` for Xedge32 and ESP32-specific APIs.
5. `opcuaapi.md` for OPC UA APIs.

If a tutorial, example, or AI skill conflicts with the API reference, trust the
API reference and fix the local guidance.

## Optional Public Skills

Load only the smallest skill that matches the task:

| Skill | Local copy | Source URL |
| --- | --- | --- |
| VFS and routing | `./.agents/reference/rtl/VFS-skill.md` | `https://realtimelogic.com/downloads/ai-skills/VFS-skill.md` |
| Authentication and authorization | `./.agents/reference/rtl/Authentication-Authorization-Skill.md` | `https://realtimelogic.com/downloads/ai-skills/Authentication-Authorization-Skill.md` |
| General web/application security | `./.agents/reference/rtl/OWASP-General-Security-Skill.md` | `https://realtimelogic.com/downloads/ai-skills/OWASP-General-Security-Skill.md` |
| SMQ real-time messaging | `./.agents/reference/rtl/SMQ-Skill.md` | `https://realtimelogic.com/downloads/ai-skills/SMQ-Skill.md` |
| SQLite write serialization | `./.agents/reference/rtl/SQLite-Skill.md` | `https://realtimelogic.com/downloads/ai-skills/SQLite-Skill.md` |
| Lua/C/C++ bindings | `./.agents/reference/rtl/Lua-Binding-Skill.md` | `https://realtimelogic.com/downloads/ai-skills/Lua-Binding-Skill.md` |

Selection rule: routing first for URL/resource-tree work, authentication for
identity or protected paths, security for exposure or review, SQLite for database
writes, SMQ for publish/subscribe or browser/device messaging, and Lua bindings
only for native C/C++ integration.

## BAS Coding Rules

- Keep server-side Lua/LSP responsible for data sources, device/runtime logic,
  authorization, validation, and HTTP/SMQ endpoints.
- Keep browser JavaScript responsible for rendering and user interaction. Do not
  embed server secrets in client code.
- Prefer BAS-native APIs and the existing example pattern over third-party
  frameworks.

## Verification

There is no single command for the whole repository. Run and test the selected
example exactly as documented in its README, commonly:

```bash
cd path/to/example
mako -l::www
```

For UI or SMQ examples, verify the browser workflow described by the README. For
SMQ broker endpoints such as `smq.lsp`, a plain HTTP request may fail because the
endpoint expects an SMQ/WebSocket handshake; test the intended client flow.
