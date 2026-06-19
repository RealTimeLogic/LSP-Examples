# AGENTS.md - Light Dashboard

Purpose
- This repo ships three dashboard variants: `custom/`, `htmx/`, and `www/`.
- All variants can run under Mako Server or Xedge.
- The default target for new work is `custom/`.
- Do not update multiple variants unless the user explicitly asks for parity.

## Variant Routing

Read [README.md](README.md) first for the user-facing overview and current variant descriptions.

When the target variant is `custom/`, read and follow [doc/custom-skill.md](doc/custom-skill.md) before making changes.

The custom skill is the source of agent-facing development guidance for:

- custom layout and color changes;
- adding, modifying, or removing custom pages;
- HTMX navigation and browser history behavior;
- CMS-level SMQ and page scopes;
- page-scoped SMQ RPC;
- native JavaScript expectations;
- packaging a single variant ZIP for Xedge deployment.

For deeper architecture notes, use [doc/custom-design.md](doc/custom-design.md).

When the target variant is `htmx/` or `www/`, use the equivalent paths under that variant and preserve that variant's existing design:

- `www/`: SSR + Pure.css.
- `htmx/`: CSR/HTMX + Pure.css.
- `custom/`: CSR/HTMX + custom CSS, two-level navigation, and CMS-level SMQ support.

## Official Documentation (Source Of Truth)

Use the official Markdown documentation bundles for native APIs. Do not invent
BAS, LSP, Lua, SMQ, Mako Server, or Xedge APIs.

- **BAS documentation bundle (`basapi.md`)**  
  https://realtimelogic.com/downloads/basapi.md

- **BAS tutorials bundle (`tutorials.md`)**  
  https://realtimelogic.com/downloads/tutorials.md

- **Mako Server tutorials bundle (`tutorials.md`)**  
  https://makoserver.net/download/tutorials.md

Reference priority:

1. `basapi.md` for BAS, Lua, LSP, SMQ, MQTT, request/response, and server API syntax, signatures, and behavior.
2. `tutorials.md` for architecture, dashboard patterns, embedded UI guidance, Xedge/Mako deployment, and security guidance.
3. If tutorial guidance conflicts with API details, trust `basapi.md`.

Important distinction for `custom/`:

- The official SMQ docs define the underlying native API.
- Custom page scripts must use the CMS page-scope API from `custom/static/cms-smq.js`.
- Do not create page-local `SMQ.Client(...)` instances in `custom/` pages.
- For page-level SMQ work, read [doc/custom-skill.md](doc/custom-skill.md) and [doc/custom-design.md#page-scopes](doc/custom-design.md#page-scopes).

Server-side Lua SMQ publish signatures are:

```lua
smq:publish(data, "topic")          -- broadcast
smq:publish(data, ptid, "subtopic") -- direct
```

Keep these signatures in broker/server code. Custom browser pages should use
the page-scope helpers documented in [doc/custom-skill.md](doc/custom-skill.md).

## Key Files

Variant-local files follow the same broad layout:

- `<variant>/.preload`: app startup.
- `<variant>/.lua/cms.lua`: mini CMS/router.
- `<variant>/.lua/menu.json`: menu and routing source of truth.
- `<variant>/.lua/www/template.lsp`: shared layout shell.
- `<variant>/.lua/www/*.html`: page fragments.
- `<variant>/static/`: variant-specific CSS and JavaScript.

Custom-only additions:

- `custom/static/cms-smq.js`: shared browser-side SMQ connection and page-scope lifecycle manager.
- `custom/SMQ/index.lsp`: SMQ connection endpoint.
- `doc/custom-skill.md`: agent skill for developing the custom variant.
- `doc/custom-design.md`: detailed custom CMS architecture notes.

## General Rules

- Always state or infer the target variant before editing.
- Prefer local assets; update CSP in the relevant `cms.lua` when adding external resources.
- Do not add query-string cache busters such as `?v=custom` to reusable examples/templates.
- Keep page fragments registered in the matching `.lua/menu.json`.
- Preserve no-JS/full-page behavior unless the user explicitly asks for JS-only behavior.
- When working on `custom/`, use modern native JavaScript unless the user asks for a specific library.

## Verification

Run the selected variant directly during development:

```bash
mako -l::<variant>
```

For example:

```bash
mako -l::custom
```

For UI/navigation changes, verify:

- direct full page load;
- menu navigation;
- browser back/forward;
- HTMX fragment behavior for HTMX/custom variants;
- relevant JavaScript syntax with `node --check`.

For deployment packaging, do not ZIP the whole repo. Package exactly one variant
directory from inside that directory, as documented in [doc/custom-skill.md](doc/custom-skill.md).
