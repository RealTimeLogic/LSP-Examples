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
cd docex/cart
mako -l::www
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

After the server starts, open the HTTP URL printed in the Mako console. The root page redirects into the cart directory handled by `.preload`.

## How it works

The example uses the BAS virtual file system model to maintain the shopping-cart interaction through directory-based logic and LSP pages.

## Packaging for Xedge

This example can be packaged as an Xedge app by creating a ZIP from the `www/` directory, so the app files are at the ZIP root. See [Xedge App Deployment](../../Xedge-App-Deployment/README.md) for the detailed deployment workflow.

```bash
cd www
zip -D -q -u -r -9 ../docex-cart.zip .
```

Upload the generated ZIP with the Xedge App Upload tool.


## Notes / Troubleshooting

- This example is primarily intended to be read together with the documentation section it accompanies.
