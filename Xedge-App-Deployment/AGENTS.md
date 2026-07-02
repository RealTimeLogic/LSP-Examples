# AGENTS.md - Xedge App Deployment

## Purpose

This example is the source layout for the `MyApp.zip` Xedge deployment tutorial. It demonstrates how an Xedge app ZIP is structured, how `.config` controls install/upgrade behavior and app metadata, and how `.preload`, LSP, and `.xlua` files fit into a packaged app.

## Read First

- `README.md` for packaging and deployment instructions.
- `www/.config` for Xedge app metadata, `install`, `upgrade`, `autostart`, `name`, and `dirname`.
- `www/.preload` for app startup/shutdown tracing.
- `www/index.lsp` for the browser-facing LSP page.
- `www/MyTest.xlua` for the `.xlua` startup/shutdown example.

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

Use the official Markdown documentation bundles for BAS, Mako Server, Xedge deployment, Lua, LSP, and `.xlua` behavior. Do not invent BAS, Mako, Xedge, Lua, LSP, or `.config` APIs.

- BAS API bundle: https://realtimelogic.com/downloads/basapi.md
- BAS tutorials bundle: https://realtimelogic.com/downloads/tutorials.md
- Mako Server tutorials bundle: https://makoserver.net/download/tutorials.md

The tutorial associated with this example is:

- https://realtimelogic.com/articles/Mastering-Xedge-Application-Deployment-From-Installation-to-Creation

## Runtime And Compatibility

- The primary target is Xedge app deployment.
- The `www/` directory can be previewed with Mako Server using `mako -l::www`, but this does not exercise the full Xedge upload/install workflow.
- The package ZIP must contain the contents of `www/` at the ZIP root.

## Key Files

- `www/.config`: Xedge package metadata. The included `dirname="myapp"` exposes the app under `/myapp/` after upload.
- `www/.preload`: traces startup and shutdown through `onunload()`.
- `www/index.lsp`: renders a simple page and server time.
- `www/MyTest.xlua`: traces `.xlua` startup and shutdown through `onunload()`.

## Change Guidance

- Keep `.config` at the root of `www/`; it must also be at the root of the generated ZIP.
- If changing `name` or `dirname`, update `README.md` so the expected Xedge URL stays correct.
- Do not add generated ZIP files to the source tree unless the user explicitly asks for a packaged artifact.
- Preserve the packaging command in `README.md` unless the Xedge packaging requirement changes.

## Verification

Preview with Mako:

```bash
cd Xedge-App-Deployment
mako -l::www
```

Package for Xedge:

```bash
cd www
zip -D -q -u -r -9 ../MyApp.zip .
```

Before uploading, verify the ZIP contains `.config` at the archive root and does not contain a leading `www/` directory.
