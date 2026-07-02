# AGENTS.md - Web-Shell

## Purpose

This example implements a Linux-oriented browser terminal. Server-side Lua starts a shell through `ba.forkpty()`, bridges the pseudo-terminal to SMQ, and the browser renders the terminal with xterm.js.

## Read First

- `README.md` for the tutorial context, run command, and Linux dependency notes.
- `www/.preload` for `ba.forkpty()` startup, shell discovery, PTY lifecycle, SMQ broker setup, authentication hooks, and resize/data handling.
- `www/index.lsp` for the SMQ endpoint handling and browser terminal client.
- `www/xterm.js` and `www/xterm.css` for the vendored terminal UI assets.

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

Use the official Markdown documentation bundles for BAS Lua, auxiliary APIs, `ba.forkpty`, SMQ, sockets, authentication, Mako Server, and LSP. Do not invent BAS, Lua, SMQ, PTY, or authenticator APIs.

- BAS API bundle: https://realtimelogic.com/downloads/basapi.md
- BAS tutorials bundle: https://realtimelogic.com/downloads/tutorials.md
- Mako Server tutorials bundle: https://makoserver.net/download/tutorials.md

## Runtime And Compatibility

- This example is Mako/Linux-oriented as written.
- It requires a server build that includes `ba.forkpty()` and an operating system with a usable shell such as `/bin/sh` or `/bin/bash`.
- It is not a generic Xedge example; do not classify it as Xedge-compatible unless PTY, shell, authentication, and OS assumptions are redesigned for the target.

## Security Notes

A browser shell is high risk. Treat this example as a controlled learning tool unless authentication, authorization, network exposure, and command restrictions are designed for the deployment.

- Keep authentication enabled for real deployments.
- Do not expose the shell to untrusted networks.
- For local-only testing, bind Mako to loopback with `host="localhost"` and `sslhost="localhost"` in `mako.conf`; the official Mako configuration docs define `host` as the HTTP interface bind setting and `sslhost` as the HTTPS interface bind setting.
- A minimal loopback-only `mako.conf` for this example is:

```lua
host="localhost"
sslhost="localhost"
apps={{name="", path="www"}}
```

- With that file in `Web-Shell/`, start Mako from the example directory with `mako` instead of `mako -l::www`.
- Review which user account and environment the shell runs under.
- Review terminal escape handling and file-system access for the target system.

## Key Files

- `www/.preload`: checks `ba.forkpty`, discovers the user's shell, creates the SMQ broker, starts one PTY per SMQ client, forwards PTY output to the browser, writes browser input to the PTY, handles resize events, and configures authentication when available.

- `www/index.lsp`: serves the terminal UI, accepts SMQ requests, connects the browser SMQ client, subscribes to PTY output, publishes input and resize messages, and initializes xterm.js.
- `www/xterm.js` and `www/xterm.css`: local terminal rendering assets.

## Change Guidance

- Keep the PTY lifecycle tied to the SMQ client lifecycle; terminate the PTY on disconnect.
- Preserve resize handling so terminal applications behave correctly.
- Do not remove the `ba.forkpty` availability check.
- If changing authentication, keep access control in `www/.preload` and test unauthenticated access explicitly.
- Avoid adding broad command shortcuts or privileged operations unless the user has specified the security model.

## Verification

```bash
cd Web-Shell
mako -l::www
```

Then verify on a Linux-capable Mako build:

- Startup does not fail with the `ba.forkpty` error.
- The browser opens the xterm.js terminal.
- Input typed in the browser reaches the shell.
- Shell output is displayed in the browser.
- Closing the browser terminates the associated PTY.
