# AGENTS.md - LSP Examples

## Purpose

This repository contains independent Barracuda App Server (BAS) examples. BAS is
the embedded web/application server C code library used by Mako Server, Xedge,
and Xedge32. LSP means Lua Server Pages.

Use this file as the repository-level baseline. If the selected example has its
own `AGENTS.md`, that file is more specific and must be read before editing.

## First Steps

- Identify the exact example, subexample, and runnable app root before changing
  files.
- Identify the target runtime: Mako Server, Xedge, Xedge32, or more than one.
  Do not assume runtime-specific APIs or lifecycle behavior are interchangeable.
- Read the selected example's `README.md` first; it is the run and verification
  contract.
- Read any local `AGENTS.md`, design note, or skill file named by the README or
  local AGENTS file.
- Inspect the existing app shape and follow its conventions before introducing
  new routing, state, or transport patterns.
- Modify only the selected example unless the user explicitly asks for
  cross-example parity.
- Keep the common example shape when adding or moving app files: root
  `README.md`, runnable app files under `www/` or the variant directory named by
  the local README.

## Source Of Truth

Do not invent BAS, Lua, LSP, SMQ, Mako, Xedge, Xedge32, or OPC UA APIs. Use the
official documentation for exact names, signatures, and behavior.

This `AGENTS.md` may be copied standalone into other work directories. Treat the
local paths below as relative to the directory containing this file.

When this file references a public BAS document or AI skill, resolve it in this
order:

1. A same-directory file with the referenced filename.
2. `./.agents/reference/rtl/` relative to this file or project.
3. The listed public source URL.

If a referenced file is missing and network access is available, download it
from the public URL and save it under `./.agents/reference/rtl/`. Record the
source URL and download date in `./.agents/reference/rtl/manifest.md` or in a
short header at the top of the cached file.

Use local copies for normal work. Re-fetch only when the user asks for
current/latest guidance, the local copy is missing, or the local copy conflicts
with observed API/runtime behavior.

For fully offline use, copy this `AGENTS.md` together with the
`./.agents/reference/rtl/` directory.

| Reference | Local copy | Source URL |
| --- | --- | --- |
| BAS API bundle | `./.agents/reference/rtl/basapi.md` | `https://realtimelogic.com/downloads/basapi.md` |
| Xedge32 and ESP32 API reference | `./.agents/reference/rtl/esp32api.md` | `https://realtimelogic.com/downloads/esp32api.md` |
| OPC UA API reference | `./.agents/reference/rtl/opcuaapi.md` | `https://realtimelogic.com/downloads/opcuaapi.md` |

Reference priority:

1. `basapi.md` for BAS API syntax, signatures, and behavior.
2. `esp32api.md` for Xedge32 and ESP32-specific APIs.
3. `opcuaapi.md` for OPC UA APIs.

If an example or AI skill conflicts with the relevant API reference, trust the
API reference and fix the local guidance.

## Optional Public Skills

Load only the smallest skill set that matches the task:

| Skill | Local copy | Source URL |
| --- | --- | --- |
| VFS and routing | `./.agents/reference/rtl/VFS-skill.md` | `https://realtimelogic.com/downloads/ai-skills/VFS-skill.md` |
| Authentication and authorization | `./.agents/reference/rtl/Authentication-Authorization-Skill.md` | `https://realtimelogic.com/downloads/ai-skills/Authentication-Authorization-Skill.md` |
| General web/application security | `./.agents/reference/rtl/OWASP-General-Security-Skill.md` | `https://realtimelogic.com/downloads/ai-skills/OWASP-General-Security-Skill.md` |
| SMQ real-time messaging | `./.agents/reference/rtl/SMQ-Skill.md` | `https://realtimelogic.com/downloads/ai-skills/SMQ-Skill.md` |
| SQLite write serialization | `./.agents/reference/rtl/SQLite-Skill.md` | `https://realtimelogic.com/downloads/ai-skills/SQLite-Skill.md` |
| Lua/C/C++ bindings | `./.agents/reference/rtl/Lua-Binding-Skill.md` | `https://realtimelogic.com/downloads/ai-skills/Lua-Binding-Skill.md` |
| Mako Server service deployment | `./.agents/reference/rtl/Deploy-Mako-Server-Skill.md` | `https://realtimelogic.com/downloads/ai-skills/Deploy-Mako-Server-Skill.md` |
| LSP browser interfaces | `./.agents/reference/rtl/Build-LSP-Web-Interfaces-Skill.md` | `https://realtimelogic.com/downloads/ai-skills/Build-LSP-Web-Interfaces-Skill.md` |

Selection rules:

- Start with VFS for URL layout, resource readers, directory callbacks, static
  trees, hidden resources, REST-style paths, WebDAV, or WFS.
- Add authentication for identity, sessions, roles, method/path permissions, or
  protected subtrees. Use it with VFS when deciding where protection is mounted.
- Add OWASP security for public exposure, production readiness, untrusted input,
  uploads, CORS, cookies, TLS, secrets, or code review. It complements, but does
  not replace, the API reference.
- Use SQLite before designing any request path that writes to SQLite.
- Use SMQ for publish/subscribe, browser/device messaging, presence, discovery,
  one-to-one messages, or synchronized clients. Use language-specific references
  for low-level non-Lua client implementation.
- Use Lua bindings only for native C/C++ integration, including `ba.*` modules,
  `ba.create.*` factories, `IoIntf`, request/response helpers, or
  `HttpDir`-derived objects exposed to Lua.
- Use Mako deployment for service/daemon installation, VPS operation, boot-time
  startup, unattended logging, or ACME operations.
- Use LSP web interfaces when choosing among server-rendered pages, htmx,
  Fetch/JSON, WebSocket RPC, and SMQ-driven browser interaction.

Common combinations:

| Task | Skills |
| --- | --- |
| Protected REST or admin subtree | VFS + authentication + OWASP |
| Database-backed browser form/API | LSP web interfaces + SQLite + OWASP |
| Live browser/device dashboard | LSP web interfaces + SMQ; add authentication/OWASP when exposed |
| Production Mako service | Mako deployment; add authentication/OWASP for remotely reachable management |
| Native sensor or protocol API | Lua bindings + the relevant runtime API; add VFS or SMQ only for its exposed interface |

## Runtime And Application Model

- Put application startup state, persistent clients, timers, shared helpers, and
  other app-lifetime resources in `.preload` or modules loaded by `.preload`.
- Provide `onunload()` whenever an application or `.xlua` program owns resources
  that require deterministic cleanup, such as sockets, timers, threads,
  database connections, mounts, or hardware handles.
- In Xedge applications, use `.xlua` for independent background programs such as
  protocol clients, hardware logic, and long-running IoT tasks. Use LSP for
  browser-facing request/response work. Confirm Xedge32-specific behavior in
  `esp32api.md`.
- Xedge `.xlua` environments inherit from the application's `.preload`
  environment. LSP pages can access application state through `app`, but do not
  inherit `.preload` variables as ordinary globals.
- Treat the application resource reader's `dir` and I/O object as runtime-owned
  application objects. Use the VFS and API references before mounting, unlinking,
  filtering, or changing response headers.

Use the correct state scope:

| Scope | Lifetime and visibility | Appropriate use |
| --- | --- | --- |
| Request command environment | One request | Request parsing, response generation, request-local values |
| `page` | Lifetime of one LSP resource; shared by all users of that page | Per-page caches or counters, never per-user secrets |
| `app` | Lifetime of one application/resource reader; shared by its pages | Configuration, shared helpers, caches, timers, persistent clients |
| Session | One authenticated/browser session | Per-user state |
| `_G` | Entire Lua state; may cross apps, pages, requests, and sessions | Deliberate process-global facilities only |

Do not store user-specific data in `page`, `app`, or `_G`. Do not use `_G` as a
shortcut for ordinary application state.

## BAS Coding Rules

- Keep server-side Lua/LSP responsible for data sources, device/runtime logic,
  authorization, validation, and HTTP/SMQ endpoints.
- Keep browser JavaScript responsible for rendering and user interaction. Do not
  embed server secrets in client code.
- Define each HTTP or message contract before implementation: method/topic,
  inputs, validation, response/payload type, errors, authorization, timeouts,
  and retry/idempotency behavior.
- Validate all external input on the server, including URL data, forms, JSON,
  headers, uploads, WebSocket frames, SMQ messages, and device data.
- Keep request handlers bounded. Move app-lifetime or background work to the
  runtime mechanism designed for it rather than retaining request objects or
  blocking a request indefinitely.
- Serialize SQLite writes through the dedicated writer pattern.
- Keep hidden application files such as `.preload`, modules, databases, keys,
  and configuration out of public URL space.
- Prefer BAS-native APIs and the existing example pattern over third-party
  frameworks.
- Keep changes small and runtime-specific unless the example explicitly supports
  multiple runtimes.

## Verification

There is no single command for the whole repository. Run and test the selected
example exactly as documented in its README, commonly:

```bash
cd path/to/example
mako -l::www
```

Verify in proportion to the changed lifecycle:

- After changing `.preload`, restart or reload the application and inspect
  startup and unload behavior; a browser refresh alone is not sufficient.
- After changing `.xlua`, verify activation, trace output, replacement of the
  previous program, and deterministic cleanup of owned resources.
- For LSP and HTTP APIs, verify method, status, content type, response body,
  validation failures, authorization failures, and side effects.
- For browser UI changes, exercise initial load, direct navigation, form or
  fragment updates, browser console errors, and at least one failure path.
- For WebSocket or SMQ endpoints, use the intended client handshake and message
  flow. A plain HTTP request to an endpoint such as `smq.lsp` is not a valid
  protocol test.
- For real-time shared state, use at least two clients and test disconnect and
  reconnect behavior.
- For service/deployment changes, verify foreground startup first, then service
  identity, paths, listeners, logs, stop/start, restart policy, and boot startup.

Inspect runtime trace/log output after actions expected to execute Lua. A file
write or successful start command proves only that the runtime accepted the
operation, not that the application executed correctly.
