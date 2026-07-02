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

- BAS API bundle: https://realtimelogic.com/downloads/basapi.md
- BAS tutorials bundle: https://realtimelogic.com/downloads/tutorials.md
- Mako Server tutorials: https://makoserver.net/download/tutorials.md
- Xedge32 and ESP32 API reference: https://realtimelogic.com/downloads/esp32api.md
- OPC UA API reference: https://realtimelogic.com/downloads/opcuaapi.md

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

- VFS and routing: https://realtimelogic.com/downloads/ai-skills/VFS-skill.md
- Authentication and authorization:
  https://realtimelogic.com/downloads/ai-skills/Authentication-Authorization-Skill.md
- General web/application security:
  https://realtimelogic.com/downloads/ai-skills/OWASP-General-Security-Skill.md
- SMQ real-time messaging:
  https://realtimelogic.com/downloads/ai-skills/SMQ-Skill.md
- SQLite write serialization:
  https://realtimelogic.com/downloads/ai-skills/SQLite-Skill.md
- Lua/C/C++ bindings:
  https://realtimelogic.com/downloads/ai-skills/Lua-Binding-Skill.md

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
