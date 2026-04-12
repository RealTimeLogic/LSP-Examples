# SQLite Shared Connection Example

## Overview

This example accompanies the [Lua-SQLite and LSP Considerations](http://realtimelogic.com/ba/doc/?url=luasql-lsp-considerations.html) tutorial. It focuses on sharing database access safely and on understanding the practical effects of SQLite locking. For additional background on locking behavior, see [Understanding SQLITE_BUSY](https://activesphere.com/blog/2018/12/24/understanding-sqlite-busy).

## Files

- `www/.preload` - Initializes the shared SQLite setup for the application.
- `www/index.lsp` - Example page used to insert data manually or automatically.

## How to run

Start the example with the Mako Server:

```bash
cd SQLite/Shared-Connection
mako -l::www
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

After the server starts:

1. Open `http://localhost`.
2. The database starts out empty. Enter data and submit the form to insert rows.
3. To automate insertion, open `http://localhost?auto=`.
4. The browser-side JavaScript then begins posting new data automatically as soon as the page loads.

## How it works

The example keeps a shared SQLite access path in the application and uses `index.lsp` to drive concurrent or repeated writes. The optional `?auto=` mode is there to make locking behavior easier to observe under repeated requests.

## Notes / Troubleshooting

- If you encounter busy or locked-database behavior, that is part of the lesson this example is designed to illustrate.
- Use the referenced articles to compare this shared-connection pattern with simpler per-request approaches.
