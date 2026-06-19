# Ready-to-Run Documentation Examples

## Overview

This directory collects examples that are referenced directly from the Real Time Logic documentation. It is meant as an index rather than as a single runnable application.

## Files

- [Shopping Cart](cart) - Example for the documentation section [The Virtual File System: Directory: Shopping Cart](https://realtimelogic.com/ba/doc/).

## How to run

Open the README in the specific subdirectory you want to try. Each documentation example has its own startup instructions.

## How it works

The directory serves as a lightweight landing page for the runnable examples that accompany the BAS documentation.

## Packaging for Xedge

The Xedge-compatible app in this directory is the `cart` example. See [Xedge App Deployment](../Xedge-App-Deployment/README.md) for the detailed deployment workflow.

```bash
cd cart/www
zip -D -q -u -r -9 ../../docex-cart.zip .
```

Upload the generated ZIP with the Xedge App Upload tool.


## Notes / Troubleshooting

- There is no single `mako -l::...` command for this directory as a whole. Run the specific example you want to explore.
