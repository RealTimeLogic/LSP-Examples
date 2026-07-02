# AGENTS.md - Lua Authentication Examples

## Purpose

This directory is a collection of three Barracuda App Server authentication examples. They are run with Mako Server commands in this repo, but the BAS authentication patterns can be adapted to Xedge app paths. The examples demonstrate protecting a full app root, protecting only a subdirectory, and manually authenticating shared page logic.

Treat this directory as a container of related app roots, not as one app to run all at once.

## Read First

1. `README.md` - overview, run commands, credentials, and security notes.
2. The selected app root: `root/`, `subdir/`, or `semiautomatic/`.
3. The selected app's `.preload` file before changing authentication behavior.
4. Matching `.login/` pages when changing form login behavior.

Do not invent BAS authentication APIs. If API details are unclear, use the official Markdown documentation bundles below.

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

1. `basapi.md` for `ba.create.authuser`, `ba.create.authenticator`, `dir:setauth`, `dir:insertprolog`, request user/session methods, and response forwarding behavior.
2. `tutorials.md` for authentication architecture, security guidance, and deployment context.
3. If tutorial guidance conflicts with API details, trust `basapi.md`.

## Example Roots

- `root/` - protects the entire application resource reader with `dir:setauth(authenticator)`. Public login assets are under `root/public/`.
- `subdir/` - protects only `my-protected/` by creating a virtual directory and inserting it as a prologue directory with `dir:insertprolog(...)`.
- `semiautomatic/` - uses a shared `emitHeader(...)` function to call `authenticator:authenticate(...)` manually for each page.

## Key Files

- `root/.preload` - selects `basic`, `digest`, or `form` from `mako.argv`, creates the auth user and authenticator, and applies it to the app root.
- `root/index.lsp` - authenticated landing page with logout handling.
- `root/.login/form.lsp` and `root/.login/failed.lsp` - form login and failure UI.
- `subdir/.preload` - creates and protects the virtual `my-protected` branch.
- `subdir/index.lsp` - public page that links to the protected branch.
- `subdir/my-protected/index.lsp` - protected page.
- `semiautomatic/.preload` - creates the authenticator and shared page list, then defines `emitHeader(...)` and `emitFooter(...)`.
- `semiautomatic/page1.lsp`, `page2.lsp`, `page3.lsp` - manually protected pages using the shared header/footer calls.

## Change Guidance

- Keep credentials obviously demo-only unless the user explicitly asks for a real credential store.
- Do not add new protected pages to `semiautomatic/` without using the shared authentication wrapper.
- Prefer directory-based protection (`root/` or `subdir/`) when the user wants safer defaults for newly added pages.
- If changing login UI, update the matching `.login/form.lsp`, `.login/failed.lsp`, and public assets for that app root.
- If changing authentication type handling in `root/` or `subdir/`, preserve the `mako.argv` selection pattern unless the user asks for a fixed mode.
- Warn users that Basic and Digest credentials may be cached by the browser during testing.

## Run And Verify

Run one app root at a time from this directory when testing with Mako Server:

```bash
cd authentication
mako -l::root
mako -l::root digest
mako -l::root form
mako -l::subdir
mako -l::subdir digest
mako -l::subdir form
mako -l::semiautomatic
```

Demo credentials are `admin` / `admin`.

Verify the intended protection boundary: `root/` should require authentication for the app, `subdir/` should leave `/` public but protect `/my-protected/`, and `semiautomatic/` should authenticate pages that call `app.emitHeader(request)`.
