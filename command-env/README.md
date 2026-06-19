# Command Environment

## Overview

This directory contains two examples showing how the [ephemeral request/response environment](https://realtimelogic.com/ba/doc/?url=lua.html#CMDE) can be used with included pages and forwarded pages.

![Request/Response Environment](https://realtimelogic.com/ba/doc/en/img/RequestResponseEnv.svg "Request/Response Environment")

## Files

- `include/` - Example showing how `response:include()` works with shared header and footer pages.
- `forward/` - Example showing how `response:forward()` hands control to other pages.
- `include/.header.lsp` and `include/.footer.lsp` - Shared layout parts used by the include example.
- `forward/first.lsp`, `forward/.second.lsp`, `forward/.third.lsp` - Pages participating in the forward chain.

## How to run

Run the examples separately:

```bash
cd command-env
mako -l::include
mako -l::forward
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

Run one command at a time. After the server starts, open the HTTP URL printed in the Mako console and follow the links or redirects shown by the example.

## How it works

The examples illustrate that the request/response command environment exists only for the lifetime of a single HTTP request, but can still be used across included or forwarded pages during that request. The `include` example keeps rendering in the same response stream, while the `forward` example transfers control to another page and stops executing the current one.

## Packaging for Xedge

This directory contains multiple app roots. Package the selected app directory, not the parent directory. See [Xedge App Deployment](../Xedge-App-Deployment/README.md) for the detailed deployment workflow.

```bash
cd include
zip -D -q -u -r -9 ../command-env-include.zip .
```

```bash
cd forward
zip -D -q -u -r -9 ../command-env-forward.zip .
```

Upload the generated ZIP with the Xedge App Upload tool.


## Notes / Troubleshooting

- Start only one of the two example apps at a time unless you intentionally want to compare them in separate server sessions.
- The examples are easiest to understand if you read the participating LSP files in order.
