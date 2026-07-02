# AGENTS.md - CGI

## Purpose

This example implements a CGI compatibility layer in Lua for Mako Server-style deployments where the `forkpty` plugin and external OS processes are available. It mounts external CGI scripts under `/cgi/` and translates BAS requests into CGI environment variables.

This is not a generic Xedge example. It depends on host OS process execution and the `forkpty` plugin.

## Read First

1. `README.md` - setup steps for `/tmp/cgi-test/`, executable scripts, and runtime limitations.
2. `www/.preload` - mounts the CGI directory.
3. `www/.lua/cgi.lua` - CGI adapter implementation.
4. `scripts/sh.cgi` and `scripts/python.cgi` - example CGI programs.

Do not invent BAS VFS, forkpty, request, response, or CGI APIs.

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

- `www/.preload` - enables module loading with `mako.createloader(io)`, loads `cgi.lua`, creates the CGI directory, and inserts it into the VFS.
- `www/.lua/cgi.lua` - maps requests to CGI environment variables, launches scripts with `ba.forkpty(...)`, parses CGI headers, and streams response bodies.
- `www/index.lsp` - redirects to `/cgi/sh.cgi`.
- `scripts/sh.cgi` and `scripts/python.cgi` - external scripts copied to the configured CGI root.

## Change Guidance

- Keep the distinction clear between BAS/LSP code and external CGI scripts.
- Do not assume this runs on Xedge; external process execution is the key constraint.
- If changing the CGI root path, update both `README.md` and `www/.preload`.
- Validate environment variables and response header parsing when changing `cgi.lua`.
- Prefer authentication around CGI directories in real deployments.

## Run And Verify

```bash
mkdir -p /tmp/cgi-test/
cp scripts/* /tmp/cgi-test/
chmod +x /tmp/cgi-test/*
cd CGI
mako -l::www
```

Verify `/cgi/sh.cgi` and `/cgi/python.cgi?textcontent=Hello%20World` return CGI output.
