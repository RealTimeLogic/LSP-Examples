# AJAX

## Overview

This example is the companion code for the [Ajax for Beginners](https://makoserver.net/articles/Ajax-for-Beginners) tutorial. It shows a minimal AJAX pattern with Lua Server Pages (LSP): the browser sends a small `POST` request in the background, the server processes the data, and the page updates without a full reload.

## Files

- `www/index.lsp` - Handles both the HTML page and the AJAX requests. The page captures keypresses in the browser, posts the pressed key code back to the same URL, logs the value on the server, and returns JSON for the browser to append to the page.

## How to run

Run the example with the Mako Server:

```bash
cd AJAX
mako -l::www
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

After the server starts, open `http://localhost/`. Type into the input field and watch the data appear in the browser while the server prints the processed values to its console.

## How it works

When the page loads, the JavaScript in `index.lsp` attaches a `keypress` handler to the text field. Each keypress is URL-encoded and sent back to the same page with `fetch(...)` as a `POST` request. The LSP code reads the `key` field, converts the numeric key code to a printable character when possible, traces the value on the server, and replies with `response:json(...)`. The browser then appends the returned character to the output area.

## Notes / Troubleshooting

- This example is intentionally small and focused on the request/response pattern, not on production-grade input handling.
- If you do not see updates in the browser, make sure JavaScript is enabled and confirm that the Mako Server is still running.
