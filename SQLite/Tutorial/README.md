# Lua SQLite Database Tutorial

## Overview

This example is the companion code for the [Lua SQLite Database Tutorial](https://makoserver.net/articles/Lua-SQLite-Database-Tutorial). It demonstrates a simple form-driven SQLite workflow with Lua Server Pages.

Documentation reference: [SQLite Lua API](https://realtimelogic.com/ba/doc/?url=luasql.html)

## Files

- `www/.preload` - Initializes the example's SQLite environment.
- `www/index.lsp` - Displays the form and performs the example database operations.
- `www/style.css` - Styling for the example page.

## How to run

Start the example with the Mako Server:

```bash
cd SQLite/Tutorial
mako -l::www
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg).

After the server starts, open `http://localhost:portno`, where `portno` is the HTTP port printed in the console. Enter data into the form and click `Submit`.

## How it works

The example uses a standard LSP page as both the HTML frontend and the request handler. The startup script prepares the SQLite resources, and `index.lsp` accepts the submitted data, performs the database work, and renders the updated page.

## Notes / Troubleshooting

- If the page opens but inserts do not appear, confirm that the startup script ran and that the application has permission to create or update its SQLite files.
