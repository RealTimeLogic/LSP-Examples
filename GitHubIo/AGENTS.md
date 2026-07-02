# AGENTS.md - GitHub IO

## Purpose

This example implements a LuaIO-compatible GitHub repository driver. It exposes a GitHub repository as a BAS IO object and mounts it behind a Web File Server/WebDAV endpoint at `/git/`.

Use this example for GitHub-backed storage, custom LuaIO implementations, WebDAV over a remote API, or Xedge IDE auxiliary-app integration.

## Read First

1. `README.md` - driver behavior, setup requirements, extended API, and security notes.
2. `www/.lua/GitHubIo.lua` - the reusable GitHub IO driver.
3. `www/.preload` - example mount setup and placeholder credentials.

Do not invent GitHub API, BAS IO, Web File Server, or WebDAV APIs.

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

- `www/.lua/GitHubIo.lua` - GitHub-backed LuaIO driver with normal IO methods and extended GitHub helpers.
- `www/.preload` - intentionally stops until repository owner, repo name, branch, and token placeholders are replaced; mounts the IO at `/git/`.

## Change Guidance

- Never commit real GitHub personal access tokens.
- Keep the intentional `error(...)` guard unless replacing placeholders with a safe local configuration pattern.
- WebDAV can create many GitHub API calls; keep examples small and warn users about rate limits.
- Empty directories are represented by `.keep`; do not remove that behavior without replacing empty-directory support.
- If adapting to Xedge, consider `xedge.auxapp()` integration and secure token storage.

## Run And Verify

Edit `www/.preload`, configure a test repository, remove the guard line, then run:

```bash
cd GitHubIo
mako -l::www
```

Open `/git/`, upload a small file, verify it appears in GitHub, and check delete/list behavior.
