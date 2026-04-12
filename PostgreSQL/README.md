# Persistent PostgreSQL Connection Example

## Overview

This example accompanies the tutorial [Using Lua to Access a PostgreSQL Database](https://makoserver.net/articles/Using-Lua-to-Access-a-PostgreSQL-Database). It shows how to keep one PostgreSQL connection object alive and reuse it for all database operations from the application.

## Files

- `mako.conf` - Holds the PostgreSQL connection settings in table `cinfo`.
- `www/.preload` - Loads the configuration, checks that `pgsql.so` is available, and creates the shared `pg` object.
- `www/.lua/pg.lua` - Helper library that wraps `pgsql.so`, maintains one persistent connection, and runs work on a database thread.
- `www/index.lsp` - Form-driven test page that inserts and lists messages from the database.

## How to run

1. Create an ElephantSQL account and compile the required C code as explained in the tutorial.
2. Open `mako.conf` and set the values in table `cinfo` using the connection details from your ElephantSQL account.
3. Save `mako.conf`.
4. Start the example from the `PostgreSQL` directory with:

```bash
cd LSP-Examples/PostgreSQL
mako
```

Because the app includes a local `mako.conf`, starting Mako in this directory loads the configured PostgreSQL example automatically.

5. Confirm that the console prints `DB connected: yes`.
6. Open `http://localhost:portno`, where `portno` is the server's listening port.
7. Enter data in the HTML form and click `Save Message`.

## How it works

`www/.preload` first verifies that the PostgreSQL Lua binding `pgsql.so` is available. It then loads `mako.conf`, creates the helper object from `www/.lua/pg.lua`, and stores it as `pg` for the rest of the app.

`pg.lua` maintains one connection, pings it when needed, resets it if the connection drops, and runs queries on a dedicated BAS thread. `index.lsp` converts the normal response to a deferred response, then asks `app.pg.run(...)` to perform the SQL work on that background thread. The page creates the `messages` table on first use, inserts any submitted text, reads the rows back, and renders them as HTML.

## Notes / Troubleshooting

- If Mako cannot load `pgsql.so`, the example stops early and prints the library search path to the trace output.
- This example depends on the `mako.conf` file in the directory, so run `mako` from inside `PostgreSQL/` rather than from somewhere else.
