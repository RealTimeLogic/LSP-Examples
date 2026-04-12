# Basic Wiki Engine

## Overview

This example is the companion code for the [URL to Database Mapping Tutorial](https://makoserver.net/articles/URL-to-Database-Mapping-Tutorial). It implements a small wiki engine by combining SQLite with a [directory function](https://realtimelogic.com/ba/doc/?url=lua.html#ba_dir), so URLs map directly to database-backed content.

## Files

- `www/.preload` - Initializes the wiki environment and database support.
- `www/index.lsp` - Shows the wiki index page with links to known entries.
- `www/.edit/create.lsp` - Page used when creating a new wiki entry.
- `www/.edit/modify.lsp` - Page used when editing an existing wiki entry.

## How to run

Start the example with the Mako Server:

```bash
cd SQLite/Wiki
mako -l::www
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

After the server starts, open `http://localhost:portno`, where `portno` is the HTTP port printed in the console.

## How it works

The wiki index page reads the stored entries from SQLite and renders them as links. When you navigate to a URL that does not yet exist, the directory-function logic can route that request into the create flow instead of returning a plain 404. Existing pages can later be updated through the modify flow.

To create a page, enter a URL that does not already exist, such as `http://localhost/my-page`, type some text, and submit the form. The main wiki index at `http://localhost` shows the list of created pages.

## Notes / Troubleshooting

- This example is intentionally minimal. It is useful for learning URL-to-database mapping, not for production wiki features.
- If a page is missing from the index, confirm that the create flow completed successfully and that the SQLite database was updated.
