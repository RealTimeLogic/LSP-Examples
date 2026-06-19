# AGENTS.md - AJAX

## Purpose

This example is a minimal Lua Server Pages AJAX pattern. `www/index.lsp` serves the HTML page and handles browser `POST` requests from `fetch(...)`, then returns JSON with `response:json(...)`.

Use this example when the task is about simple request/response browser updates without WebSockets, SMQ, or a larger application framework.

## Read First

1. `README.md` - overview, run command, and tutorial link.
2. `www/index.lsp` - the complete server-side and browser-side example.

Do not invent BAS, LSP, request, response, or JSON APIs. If API details are unclear, use the official Markdown documentation bundles below.

## Official Documentation (Source Of Truth)

- **BAS documentation bundle (`basapi.md`)**  
  https://realtimelogic.com/downloads/basapi.md

- **BAS tutorials bundle (`tutorials.md`)**  
  https://realtimelogic.com/downloads/tutorials.md

- **Mako Server tutorials bundle (`tutorials.md`)**  
  https://makoserver.net/download/tutorials.md

Reference priority:

1. `basapi.md` for LSP, request, response, form data, JSON, and Lua API details.
2. `tutorials.md` for architecture and tutorial context.
3. If tutorial guidance conflicts with API details, trust `basapi.md`.

## Key Files

- `www/index.lsp` - single-file LSP page. On `POST`, reads `request:data"key"`, converts key codes to display text, logs with `trace(...)`, and returns JSON. On normal `GET`, renders the HTML, CSS, and browser JavaScript.

## Change Guidance

- Keep this example small; it is intentionally a beginner AJAX example.
- Preserve the same-page `GET` plus `POST` structure unless the user asks for separate endpoints.
- Keep request parsing explicit and easy to read.
- If changing returned data, update both the LSP `response:json(...)` payload and the browser `fetch(...)` response handling.
- Do not add WebSockets or SMQ here; use `AJAX-Over-WebSockets` or `SMQ-examples/RPC` for those patterns.

## Run And Verify

Run from this directory:

```bash
cd AJAX
mako -l::www
```

Verify by opening the URL printed by Mako Server, typing into the input field, checking that the page appends returned characters, and confirming the Mako console traces keypress data.
