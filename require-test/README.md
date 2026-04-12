# How to Add a `require` Search Path to a Mako Server Application

## Overview

This example accompanies the [`mako.createloader(io)` documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#mako_createloader). It shows how to configure Lua module loading for files stored in an application's own IO tree.

## Files

- `www/.preload` - Sets up the module loader for the application.
- `www/index.lsp` - Demonstrates loading the example modules.
- `www/helloworld1.lua` - Example Lua module at the application root.
- `www/.lua/helloworld2.lua` - Example Lua module in the `.lua` directory.
- `www/.lua/subdir/helloworld3.lua` - Example Lua module in a nested subdirectory.

## How to run

Start the example with the Mako Server:

```bash
cd require-test
mako -l::www
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

## How it works

The startup script creates a loader bound to the application's IO. That makes it possible to use Lua's normal `require(...)` mechanism for modules stored inside the application package instead of relying only on the default global search path.

## Notes / Troubleshooting

- If `require(...)` fails, confirm that `.preload` ran and that the module path inside the app matches the name passed to `require`.
- Hidden directories such as `.lua` are normal for BAS applications and are still available server-side.
