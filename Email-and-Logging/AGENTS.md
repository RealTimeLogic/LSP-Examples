# AGENTS.md - Email And Logging

## Purpose

This directory contains SMTP email examples and a Mako logging/email example. The `text`, `html`, and `eml` app roots send email directly with `socket.mail()`. The `log` app root demonstrates Mako Server logging and emailed error reports.

This is a mixed collection: direct SMTP examples can be adapted to Xedge email settings, while `log/` is Mako-specific.

## Read First

1. `README.md` - overview, SMTP configuration, and each variant's behavior.
2. `mako.conf` - demo SMTP/logging configuration for Mako Server runs.
3. The selected app root: `text/`, `html/`, `eml/`, or `log/`.

Do not invent SMTP, socket.mail, Mako logging, or module loading APIs.

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

## Variants

- `text/` - sends a plain-text email with `socket.mail()`.
- `html/` - sends HTML email with a plain text fallback and inline image.
- `eml/` - parses `data/BAS-Info.eml` with the bundled EML parser and sends it.
- `log/` - uses `mako.log()` and `mako.conf` logging settings; this variant is Mako-specific.

## Key Files

- `mako.conf` - demo SMTP settings and Mako log email settings.
- `text/.preload` - plain text SMTP send.
- `html/.preload` - multipart HTML SMTP send with inline `data/BAS-Logo.png`.
- `eml/.preload` - loads the bundled `eml` parser and sends a parsed EML message.
- `eml/.lua/eml/` - reusable EML parser modules for this example.
- `log/.preload` and `log/index.lsp` - Mako logging and emailed exception demonstration.

## Change Guidance

- Never commit real SMTP passwords or production recipient addresses.
- Keep direct email examples (`text`, `html`, `eml`) separate from the Mako logging example (`log`).
- For Xedge adaptation, use the target's email configuration model instead of assuming `mako.conf` and `mako.log()`.
- Preserve `mako.exit()` in direct send examples unless the user wants a long-running app.
- If changing the EML parser or template, verify MIME headers, inline images, HTML body, and text fallback.

## Run And Verify

Configure SMTP in `mako.conf`, then run one app root at a time:

```bash
cd Email-and-Logging
mako -l::text
mako -l::html
mako -l::eml
mako -l::log
```

Verify direct send examples exit after attempting delivery. For `log/`, verify log flushing and request-triggered error reporting according to the README.
