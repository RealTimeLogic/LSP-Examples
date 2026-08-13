# AGENTS.md - BAS, Mako, and Xedge Examples

## Purpose

This repository contains independent examples for the Barracuda App Server
(BAS) ecosystem:

- **BAS** is the embedded C/C++ web and application server library.
- **Mako Server** is a standalone BAS runtime for desktop, server, and embedded
  Linux development and deployment.
- **Xedge** is a BAS-powered application environment commonly embedded in a
  product or firmware image.
- **Xedge32** is the ESP32 edition of Xedge and adds ESP32 hardware APIs.
- **LSP** means Lua Server Pages: HTML resources that execute server-side Lua.

Examples are independent teaching applications, not one monolithic program.
Keep changes scoped to the selected example and runtime.

## Non-Negotiable Start Gate

Do not analyze, edit, generate, or test repository files until both of these
steps are complete:

1. Download and read all 11 mandatory references and skills listed below.
2. Identify the selected example, its runnable app root, its target runtime,
   and its local instructions.

Do not continue with a partial reference set or guess an undocumented API.

## Mandatory Reference Bootstrap

At the beginning of a task, create `./.agents/reference/rtl/` relative to this
file and download or refresh every file in the two tables below. Save each file
using its listed local filename. Verify that every response succeeded and every
file is non-empty; an HTML error page is not a valid reference download.

Create or update `./.agents/reference/rtl/manifest.md` with:

- download date;
- source URL;
- local filename;
- any download or validation failure.

Read all downloaded references and skills before making changes. The
task-specific guidance later in this file determines which skills are most
important for the implementation; it does not make the other downloads
optional.

### If Downloading Fails

If network or filesystem restrictions block a download:

1. Ask for the elevated network or filesystem permissions required to download
   and save the files.
2. Retry after permission is granted.
3. If permission is unavailable or downloading still fails, stop before
   modifying the repository.
4. Give the user a copy-ready list of every missing file. Each item must contain
   the clickable download link and exact destination path under
   `./.agents/reference/rtl/`.
5. Ask the user to provide the files locally and resume only after all 11 files
   are accessible and non-empty.

For an explicitly offline workflow, the user may supply this `AGENTS.md` with a
complete `./.agents/reference/rtl/` directory. Verify all files before using
the offline bundle.

### API Sources Of Truth

| Reference | Local copy | Download |
| --- | --- | --- |
| BAS, Lua, LSP, Mako, and Xedge API bundle | `./.agents/reference/rtl/basapi.md` | [Download basapi.md](https://realtimelogic.com/downloads/basapi.md) |
| Xedge32 and ESP32 API reference | `./.agents/reference/rtl/esp32api.md` | [Download esp32api.md](https://realtimelogic.com/downloads/esp32api.md) |
| OPC UA Lua API reference | `./.agents/reference/rtl/opcuaapi.md` | [Download opcuaapi.md](https://realtimelogic.com/downloads/opcuaapi.md) |

API priority:

1. Use `basapi.md` for BAS, Lua, LSP, Mako, Xedge, VFS, request/response,
   database, and runtime APIs.
2. Use `esp32api.md` for Xedge32 hardware and ESP32-specific behavior.
3. Use `opcuaapi.md` for OPC UA Client, Server, PubSub, certificates, and
   interoperability behavior.

If an example, README, or skill conflicts with an applicable API reference,
the API reference wins. Report the conflict and correct local guidance when it
is in scope.

### Required Skills

| Skill | Local copy | Download |
| --- | --- | --- |
| BAS virtual filesystem and routing | `./.agents/reference/rtl/VFS-skill.md` | [Download VFS-skill.md](https://realtimelogic.com/downloads/ai-skills/VFS-skill.md) |
| Authentication and authorization | `./.agents/reference/rtl/Authentication-Authorization-Skill.md` | [Download Authentication-Authorization-Skill.md](https://realtimelogic.com/downloads/ai-skills/Authentication-Authorization-Skill.md) |
| General web and application security | `./.agents/reference/rtl/OWASP-General-Security-Skill.md` | [Download OWASP-General-Security-Skill.md](https://realtimelogic.com/downloads/ai-skills/OWASP-General-Security-Skill.md) |
| SMQ real-time messaging | `./.agents/reference/rtl/SMQ-Skill.md` | [Download SMQ-Skill.md](https://realtimelogic.com/downloads/ai-skills/SMQ-Skill.md) |
| SQLite dedicated writer pattern | `./.agents/reference/rtl/SQLite-Skill.md` | [Download SQLite-Skill.md](https://realtimelogic.com/downloads/ai-skills/SQLite-Skill.md) |
| BAS Lua/C/C++ bindings | `./.agents/reference/rtl/Lua-Binding-Skill.md` | [Download Lua-Binding-Skill.md](https://realtimelogic.com/downloads/ai-skills/Lua-Binding-Skill.md) |
| Mako Server deployment | `./.agents/reference/rtl/Deploy-Mako-Server-Skill.md` | [Download Deploy-Mako-Server-Skill.md](https://realtimelogic.com/downloads/ai-skills/Deploy-Mako-Server-Skill.md) |
| LSP browser interfaces | `./.agents/reference/rtl/Build-LSP-Web-Interfaces-Skill.md` | [Download Build-LSP-Web-Interfaces-Skill.md](https://realtimelogic.com/downloads/ai-skills/Build-LSP-Web-Interfaces-Skill.md) |

## Instruction And Source Priority

Use these rules together:

- The user's requested scope and constraints control the task.
- This file defines repository-wide working rules.
- The nearest example-specific `AGENTS.md` adds or narrows rules for that
  directory and must be read before editing there.
- The selected example's `README.md` defines its runnable root, packaging,
  user workflow, and verification contract.
- Files named by `read_next`, a local README, or local `AGENTS.md` must be read
  before changing the behavior they describe.
- Official API references control API names, signatures, and runtime behavior.
- Existing source code controls current local structure unless it conflicts
  with the requested change or an official API contract.

Do not silently resolve a meaningful contradiction. State it and choose the
official, runtime-correct behavior.

## Select The Example Before Editing

Use `.ai/main-ai-catalog.json` to find candidates. Each catalog entry records:

- `compatibility` and `run` commands;
- `use_when` and `avoid_when` guidance;
- protocols and topics;
- `read_next` files;
- the per-example `catalog_path`.

Then follow this workflow:

1. Match the user's goal to catalog `use_when`, `avoid_when`, runtime, and
   protocol fields.
2. Read the candidate's per-example catalog, nearest `AGENTS.md`, and README.
3. Identify the exact variant or subexample. A directory may contain several
   independent apps.
4. Identify the runnable app root: commonly `www/`, a variant directory, or the
   directory named by the README.
5. Confirm whether the task targets Mako, Xedge, Xedge32, or more than one.
6. State the selected scope and planned runtime verification before editing
   when the choice is not obvious.

Do not update sibling examples or multiple variants merely for consistency.
For example, `Light-Dashboard/custom`, `Light-Dashboard/htmx`, and
`Light-Dashboard/www` are separate variants. Change only the selected variant
unless the user explicitly requests parity.

## Runtime Decision Guide

| Runtime | Use it for | Important distinctions |
| --- | --- | --- |
| Mako Server | Desktop/server development, embedded Linux, services, VPS deployments, and testing BAS apps | Standalone executable; loads directory or ZIP applications; application-private modules should use `appreq` |
| Xedge | Product-integrated BAS deployments and browser-managed application packages | App package normally includes `.config`; supports `.preload`, LSP, and independent `.xlua` programs |
| Xedge32 | ESP32 firmware and hardware-facing examples | Xedge application model plus ESP32 GPIO, I2C, ADC, PWM, camera, OTA, Wi-Fi, and storage constraints |
| Custom BAS integration | Native products embedding BAS directly | C/C++ startup decides enabled Lua modules, trackers, I/O, directories, and native bindings |

Do not assume Mako-only modules, filesystem layout, process control, service
options, or desktop resources exist in Xedge/Xedge32. Do not assume an Xedge32
hardware API exists in generic Xedge or Mako.

Mako is usually the fastest development host. A compatible application can be
developed and tested with Mako and later packaged for Xedge or Xedge32, but the
target runtime must still be tested. Desktop simulation does not prove hardware
behavior.

## BAS Application Model

### Application Files

Common files have distinct roles:

- `.preload`: application startup, shared app state, mounts, persistent
  clients, timers, database setup, and lifecycle ownership.
- `.lua/`: private server-side Lua modules.
- `.config`: Xedge package metadata and startup/base-URL configuration.
- `.xlua`: independent Xedge/Xedge32 background program with its own lifecycle.
- `*.lsp`: request-driven server-side Lua embedded in HTML or response content.
- static HTML, CSS, JavaScript, images, and fonts: browser resources.

Keep writable databases, logs, secrets, uploads, and mutable configuration in a
writable data/home I/O location, not inside a deployed application ZIP.

### Module Loading

- Use `appreq"module"` for modules private to the current Mako or Xedge
  application. It provides application-local caching and preserves the app
  environment across reloads.
- In an LSP page, call `app.appreq"module"` when loading a private app module
  directly.
- Use standard `require` for built-in Mako/BAS modules and deliberately shared
  process-wide modules.
- Do not add `mako.createloader(io)` to new applications merely to make private
  `require` calls work. Preserve an old example's loader only when modernization
  is outside the requested scope.
- Do not use global `require` for mutable application-private state that must be
  released during application hot reload.

### Lifecycle

- The code that creates a resource owns its cleanup.
- Provide `onunload()` for mounts, timers, threads, sockets, database
  connections, protocol clients, and other app-lifetime resources.
- Unlink inserted directories and stop/close owned resources during unload.
- Do not retain a request, response, command environment, or request-backed
  reader after the request ends.
- Verify both startup and unload/reload behavior. A successful browser refresh
  does not test lifecycle cleanup.

### State Scope

| Scope | Lifetime | Correct use |
| --- | --- | --- |
| Request command environment | One request and its includes/forwards | Request parsing, response generation, request-local values |
| `page` | Persistent table associated with one LSP resource | Per-page caches/counters shared by requests; never user secrets |
| `app` | One application instance | Shared services, configuration, helpers, caches, and owned resources |
| Session | One browser/authenticated session | Per-user state |
| `_G` | Entire Lua state, potentially across applications | Deliberate process-global facilities only |

Do not put per-user data in `page`, `app`, or `_G`. Avoid naming an ordinary
callback parameter `_ENV`; use `env` when receiving an explicit command
environment so the global lexical `_ENV` is not accidentally shadowed.

## Virtual Filesystem And Routing

BAS routes through a chain of directory objects. Apply these rules:

- Prefer a named `ba.create.dir("name")` for a real sub-application or security
  boundary instead of manually dispatching its path from a root callback.
- Use directory priority deliberately. Higher-priority handlers can filter or
  override lower-priority resources; low-priority directories can provide
  fallbacks such as an application 404 page.
- A directory callback must return `true` when it handled the request.
- It must return `false` when the resource is not found so VFS lookup can
  continue. Do not rely on `nil`, and do not emit a 404 merely because one
  callback does not recognize the path.
- Insert static/resource readers before a dynamic fallback when static assets
  should take precedence.
- Use `dir:baseuri()` and mount-aware URL helpers. Do not hard-code `/` when an
  application may run under a base path.
- Keep `.preload`, `.lua`, databases, keys, and private configuration outside
  public resource space.
- Use `ba.openio`, `ba.mkio`, and resource readers as documented. Do not assume
  disk-only paths when the app may be deployed as a ZIP.
- Mount authentication at the directory boundary it protects. Hidden menu
  links and client-side checks are not authorization.

Read `VFS-skill.md` before changing mounts, resource readers, directory
callbacks, WebDAV/WFS, fallback routing, authentication boundaries, or
mount-safe URLs.

## Browser And Protocol Interface Choice

Choose the smallest interaction model that fits the workflow:

| Need | Preferred starting point | Response/message form |
| --- | --- | --- |
| Initial page or ordinary navigation | Full-page LSP | HTML document |
| Browser action updates one region | htmx + LSP | HTML fragment |
| Programmatic browser API | Fetch | JSON or a defined binary/text contract |
| Correlated calls over one persistent channel | WebSocket RPC | Explicit request/reply envelope |
| Topics, presence, devices, or synchronized clients | SMQ | Typed topic/subtopic messages |

- Do not introduce JSON when the browser only needs an HTML fragment.
- Do not introduce WebSockets or SMQ merely to avoid a page reload.
- For htmx, define direct-navigation behavior and ensure fragment endpoints do
  not accidentally return login/full-page HTML where the client expects a
  fragment.
- For WebSocket RPC, define correlation IDs, timeouts, disconnect behavior, and
  error envelopes.
- For SMQ, define topics, subtopics, payload types, readiness, authorization,
  reconnect behavior, and subscription/state restoration before coding.
- Keep browser rendering and interaction in JavaScript; keep validation,
  authority, device logic, and secrets on the server.
- Preserve local/vendor browser dependencies used by an example. Do not add a
  CDN dependency to an offline or embedded example unless explicitly requested.

For device-management interfaces, prefer the reusable
`Light-Dashboard/custom` architecture unless the user requests another variant.
Read `Light-Dashboard/AGENTS.md` and `Light-Dashboard/doc/custom-skill.md`
before changing it.

## Request, Response, And Input Rules

- Define the endpoint contract first: method, path/topic, input shape, limits,
  authorization, output type, status/errors, timeout, retry, and idempotency.
- Treat URL data, headers, cookies, forms, JSON, raw bodies, uploads,
  WebSocket/SMQ messages, files, database rows, and device input as untrusted.
- Use BAS request parsers/readers documented for the body format. Do not
  hand-parse structured input when BAS provides the parser.
- Use `request:rawrdr()` when the request body is one streamable payload. Use
  multipart handling when the protocol actually needs multipart fields/files,
  and account for documented buffering limits.
- Encode output for its context: HTML text, attribute, URL, JSON, JavaScript,
  SQL, log, or protocol payload.
- Do not use GET for state-changing operations.
- Keep normal request handlers bounded. Use deferred response handling only
  when the response must complete asynchronously and follow the documented
  thread/response contract.

## SQLite And Concurrency

For SQLite-backed examples:

- Serialize every schema change and write through one dedicated BAS writer
  thread per database.
- Let that thread own one persistent write connection.
- Queue `CREATE`, `ALTER`, `DROP`, `INSERT`, `UPDATE`, and `DELETE`; do not write
  from request threads or from multiple independent writer connections.
- Short-lived read connections are acceptable when cursors and connections are
  closed deterministically.
- Keep transactions short. Do not hold a write transaction across network I/O,
  sleeps, or user interaction.
- Do not use a request's normal `response` object from the database writer
  thread.
- Treat Mako `sqlutil` as a convenience API, not as a replacement for the
  dedicated writer ownership pattern.

Read `SQLite-Skill.md` before designing or changing a SQLite write path.

## Authentication, Authorization, And Security

- Authentication establishes identity; authorization decides what that identity
  may do. Implement and test both.
- Protect the correct VFS subtree and enforce authorization on every request,
  fragment, API call, upload/download, WebDAV/WFS method, and persistent-channel
  action.
- Protect state-changing browser requests against CSRF.
- Use generic authentication errors; do not reveal account existence or exact
  failure causes through text, status, URL, timing, or response shape.
- Keep secrets out of source, browser code, URLs, logs, and generated examples.
- Treat session URLs, bearer tokens, invitation links, and download links as
  credentials.
- Validate file paths and permissions server-side. Do not expose uploaded files
  as executable LSP/Lua/HTML unless that is the explicit authorized design.
- Apply TLS, secure cookies, origin policy, rate/resource limits, and
  deny-by-default authorization for remotely exposed applications.
- Do not describe a teaching example as production-ready unless its threat
  model, hardening, and failure paths were explicitly reviewed and tested.

Read both the authentication and OWASP skills for any public, authenticated,
administrative, upload, WebDAV/WFS, or device-control surface.

## Native Bindings, Hardware, And Industrial Protocols

- For Lua/C/C++ bindings, use declarations from the target BAS headers. Do not
  recreate structs, enums, type IDs, or BAS macros from memory or examples.
- Never call the Lua C API while the BAS dispatcher mutex is released.
- Define native object ownership, garbage collection, callback references,
  blocking behavior, and unload order before implementing a binding.
- For Xedge32, inspect and report board assumptions before changing code: pins,
  buses, channels, timers, camera map, power, storage, broker, topics, and
  network requirements.
- Ask whether the user's hardware matches those assumptions when it is not
  already known.
- For OPC UA, use `opcuaapi.md` to choose Client/Server versus PubSub and to
  implement certificates, security policies, subscriptions, and
  interoperability correctly.
- Simulation validates application logic only. Do not claim ESP32, protocol,
  timing, electrical, or device validation without the target hardware/system.

## Editing Rules

- Read before editing and preserve the example's established architecture.
- Keep changes small and within the selected app root.
- Do not modernize unrelated legacy code merely because a newer API exists.
- Prefer BAS-native APIs and existing local helpers over new dependencies.
- Do not duplicate shared helpers without a concrete ownership reason.
- Keep static resources, private Lua modules, writable data, and deployment
  artifacts in their intended boundaries.
- Do not commit generated ZIPs, databases, logs, credentials, reference caches,
  or test output unless the user explicitly requests those artifacts.
- Preserve unrelated user changes in a dirty worktree.
- Update the selected README when run commands, URLs, prerequisites,
  configuration, packaging, or user-visible behavior change.
- Update the local `AGENTS.md`, skill, or design note when its contract changes.

If a per-example `doc/ai-catalog.json` changes, rebuild the generated root
catalog from `.ai/`:

```text
cd .ai
python build-main-ai-catalog.py --check
python build-main-ai-catalog.py
```

Review the resulting `.ai/main-ai-catalog.json` diff; do not hand-edit that
generated file.

## Verification Contract

There is no repository-wide runtime test. Use the selected example's README and
local `AGENTS.md`. A common Mako command is:

```text
cd path/to/example
mako -l::www
```

The actual runnable root may differ. Do not guess it.

Verify in proportion to the changed behavior:

- **Startup/lifecycle:** app starts cleanly; expected trace appears; reload or
  stop invokes cleanup; restart does not duplicate mounts, timers, threads, or
  subscriptions.
- **HTTP/LSP:** method, status, content type, body, direct navigation,
  validation failures, authorization failures, and side effects.
- **Browser UI:** initial load, navigation, forms, htmx fragments, responsive
  layout, browser console, network errors, and at least one failure path.
- **Database:** schema creation/migration, writer-thread behavior, persistence,
  concurrent reads/writes, cleanup, and restart.
- **Authentication:** anonymous, valid, invalid, insufficient-role, logout, and
  direct protected-resource access.
- **SMQ/WebSocket:** intended handshake, two-client behavior where applicable,
  reconnect, restored subscriptions/state, malformed messages, and denied
  actions. A plain HTTP GET is not a valid protocol test.
- **Xedge package:** `.config` is at ZIP root, no unintended leading directory
  exists, install/start works, and unload/replacement works.
- **Xedge32/hardware:** deployment to the target, actual I/O/protocol behavior,
  reconnect/reboot, and documented hardware assumptions.
- **Deployment/service:** foreground startup first, then service identity,
  absolute paths, listeners, certificates, logs, stop/start, restart policy,
  and boot behavior.

Inspect BAS/Mako/Xedge trace output after actions expected to run Lua. A file
write, HTTP 200, or successful app load alone does not prove the intended code
executed correctly.

## Stop And Report

Stop and ask the user instead of inventing a workaround when:

- an official API is missing, contradictory, or behaves differently from its
  documentation;
- required runtime, hardware, credentials, certificates, or external services
  are unavailable;
- the target example or variant is ambiguous and choosing incorrectly would
  overwrite or redesign user work;
- validation requires destructive data changes not explicitly authorized;
- a download in the mandatory reference bootstrap cannot be completed.

When finishing, report:

- selected example, variant, app root, and runtime;
- files changed and behavior implemented;
- exact commands/tests run and their results;
- anything not tested and the remaining risk;
- any official-documentation conflict that needs correction.
