# AGENTS.md - JSON File Server

## Purpose

This example combines BAS authentication and authorization with a Web File Server/WebDAV endpoint. It uses a JSON user database, optional ACL authorizer constraints, HTTP Digest authentication, and `request:login()` for programmatic login testing.

Use it for JSON user databases, role-based authorization, file-server ACLs, and comparing authentication-only versus authentication-plus-authorization behavior.

## Read First

1. `README.md` - users, roles, ACL behavior, and testing notes.
2. `www/.preload` - Web File Server, JSON users, authorizer constraints, and file tree setup.
3. `www/index.lsp` - programmatic login test page.
4. `www/logout.lsp` - logout behavior and Digest limitation notes.
5. `mako.conf` - authorizer toggle for Mako Server tests.

Do not invent BAS JSON user, authenticator, authorizer, Web File Server, or request login APIs.

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

- `www/.preload` - creates the WebDAV root, mounts `/fs/`, defines users and ACL constraints, installs authenticator/authorizer, and creates sample family directories.
- `www/index.lsp` - tests `request:login(username)` and links to Digest-protected `/fs/`.
- `www/logout.lsp` - handles logout for programmatic login and explains browser-controlled Digest credentials.
- `mako.conf` - optional authorizer toggle for comparison testing.

## Change Guidance

- Keep authentication and authorization concepts separate in explanations and code.
- If changing users, roles, or ACLs, update `createUserDB()` and `createConstraints()` together.
- Preserve the authorizer toggle when demonstrating behavior differences.
- For Xedge adaptation, replace or expose the `mako.conf` toggle through an Xedge-appropriate setting.
- Do not use demo passwords in production.

## Run And Verify

```bash
cd JSON-File-Server
mako -l::www
```

Test `/fs/` with Digest users `guest`, `kids`, `mom`, and `dad`, then test the programmatic login form and compare behavior with the authorizer disabled.
