# AGENTS.md - WebDAV And Web File Server

## Purpose

This example mounts a BAS Web File Server and WebDAV endpoint at `/fs/`, then protects it with a simple authenticator. It demonstrates writable IO selection, WebDAV lock-directory setup, Web File Server creation, authentication, and cleanup on unload.

Use this example for BAS Web File Server and WebDAV work.

## Read First

1. `README.md` - overview, run command, credentials, and WebDAV notes.
2. `www/.preload` - complete file-server setup.

Do not invent BAS IO, WebDAV, Web File Server, or authenticator APIs.

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

- `www/.preload` - selects the writable IO, prepares a WebDAV lock directory, loads `wfs`, creates `ba.create.wfs("fs", ...)`, inserts the directory, protects it with `admin` / `admin`, and unlinks it in `onunload()`.

## Change Guidance

- Review IO selection when adapting to Xedge or embedded targets; storage may be `disk`, `sd`, or another configured IO.
- Preserve lock-directory handling; WebDAV clients depend on correct lock behavior.
- Replace demo `admin` / `admin` credentials for non-demo use.
- Keep `/fs/` focused on the file server unless the user asks for surrounding UI pages.
- On Windows, avoid recommending direct mapping to `http://localhost/fs/`; use a more specific path as noted in the README.

## Run And Verify

```bash
cd File-Server
mako -l::www
```

Open `/fs/`, log in with `admin` / `admin`, upload/download a small file, and test WebDAV mapping if relevant.
