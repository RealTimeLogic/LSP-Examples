# AGENTS.md - HTML Form

## Purpose

This beginner example shows how one LSP page can render an HTML form, receive submitted form data, and store a simple value in the session.

Use it for basic form-handling and session examples, not production authentication.

## Read First

1. `README.md` - overview and run command.
2. `www/index.lsp` - complete form and session example.

Do not invent LSP, request, response, form data, or session APIs.

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

- `www/index.lsp` - reads `request:data()`, checks `request:method()`, stores `username` in `request:session(true)`, and terminates the session on logout.

## Change Guidance

- Keep this example small and beginner-focused.
- Do not turn this into production authentication; refer users to `authentication`, `JSON-File-Server`, `fs-sso`, or `WebAuthn` for real authentication patterns.
- If adding form fields, update both the HTML form and server-side form processing.
- Escape or validate user-provided output if the example evolves beyond a controlled beginner demo.

## Run And Verify

```bash
cd html-form
mako -l::www
```

Submit a username, verify it is shown from session state, then submit the logout button to terminate the session.
