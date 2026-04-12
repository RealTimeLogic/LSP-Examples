# htmx Examples

## Overview

[htmx](https://htmx.org/) is a lightweight JavaScript library that updates parts of a page by making simple HTTP requests and swapping in server-rendered HTML. That makes it a strong match for Lua Server Pages (LSP), where the server already excels at generating HTML directly.

This directory currently contains the introductory example used in the tutorial [LSP + htmx: A Powerful Duo for Embedded Web Apps](https://realtimelogic.com/articles/LSP-htmx-A-Powerful-Duo-for-Embedded-Web-Apps).

## Files

- `introduction/index.html` - The browser-facing page for the introductory htmx example.
- `introduction/users.lsp` - Server-side LSP endpoint that returns the HTML fragment used by the page.

## How to run

Start the introduction example with the Mako Server:

```bash
cd LSP-Examples/htmx
mako -l::introduction
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

After the server starts, open `http://localhost:portno`, where `portno` is the HTTP port printed in the console.

## How it works

The browser loads `index.html`, and htmx issues HTTP requests to `users.lsp` whenever the page needs updated server-rendered content. Instead of exchanging JSON and manually rebuilding the UI in JavaScript, the server returns ready-to-insert HTML fragments.

## Notes / Troubleshooting

- If the page loads but nothing updates, confirm that `users.lsp` is being served and that JavaScript is enabled.
- This example keeps the frontend intentionally small so the htmx request/response pattern is easy to inspect.
