# Shopping Cart

## Overview

This example accompanies the documentation section [The Virtual File System: Directory: Shopping Cart](https://realtimelogic.com/ba/doc/en/VirtualFileSystem.html#directory). It demonstrates a shopping-cart style flow implemented with BAS directory logic.

## Files

- `www/.preload` - Initializes the example.
- `www/.cart.lsp` - Shared shopping-cart logic used by the application.
- `www/index.lsp` - Main page for the shopping-cart example.

## How to run

Start the example with the Mako Server:

```bash
cd LSP-Examples/docex/cart
mako -l::www
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

## How it works

The example uses the BAS virtual file system model to maintain the shopping-cart interaction through directory-based logic and LSP pages.

## Notes / Troubleshooting

- This example is primarily intended to be read together with the documentation section it accompanies.
