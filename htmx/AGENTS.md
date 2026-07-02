# AGENTS.md - htmx Examples

## Purpose

This directory currently contains one introductory htmx example showing browser-side fragment replacement with server-rendered HTML from an LSP endpoint.

Treat this as a container for htmx examples. The current runnable app root is `introduction/`.

## Read First

1. `README.md` - overview and run command.
2. `introduction/index.html` - htmx client markup.
3. `introduction/users.lsp` - server-rendered HTML fragment.

Do not invent LSP, request, response, or htmx behavior.

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

- `introduction/index.html` - loads htmx from CDN and uses `hx-get`, `hx-target`, and `hx-swap` to request `users.lsp`.
- `introduction/users.lsp` - returns an HTML fragment containing a user list.
- `introduction/style.css` - page styling.

## Change Guidance

- Preserve the server-rendered HTML fragment pattern; this is not a JSON API example.
- If changing endpoint paths, update the `hx-*` attributes and file names together.
- Keep the introductory example small unless adding a new child example under a separate directory.
- If adding more htmx examples, give each independent app its own directory and update `README.md`.

## Run And Verify

```bash
cd htmx
mako -l::introduction
```

Open the printed URL, click the button, and verify the `#userList` area swaps in the HTML returned by `users.lsp`.
