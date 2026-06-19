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
