# File Upload

## Overview

This directory contains two upload examples:

- a blocking example that is easier to understand and simpler to integrate
- an asynchronous example designed for handling a larger number of concurrent uploads

Both examples support drag-and-drop uploads from the browser and standard HTML form uploads. The sample UI focuses on firmware uploads, but the same patterns can be adapted for other file types.

## Files

- [Blocking upload example](blocking/) - Simpler example built around blocking request APIs.
- [Asynchronous upload example](asynchronous/) - More advanced example built around the asynchronous upload directory object.

## How to run

Open the README in either `blocking/` or `asynchronous/` and run that specific example.

## How it works

The blocking example uses direct request-handling APIs and is a good starting point for most projects. The asynchronous example uses a more complex object-based design that can support many concurrent uploads.

You may also want to consider the ready-to-use [Web File Manager](https://realtimelogic.com/ba/doc/?url=lua.html#ba_create_wfs), which already includes upload support. You can test that interface in the [online tutorial](https://tutorial.realtimelogic.com/fs/).

## Packaging for Xedge

This directory contains multiple app roots. Package the selected app directory, not the parent directory. See [Xedge App Deployment](../Xedge-App-Deployment/README.md) for the detailed deployment workflow.

```bash
cd blocking/www
zip -D -q -u -r -9 ../../upload-blocking.zip .
```

```bash
cd asynchronous/www
zip -D -q -u -r -9 ../../upload-asynchronous.zip .
```

Upload the generated ZIP with the Xedge App Upload tool.


## Notes / Troubleshooting

- Choose the blocking example first unless you specifically need high upload concurrency.
- The subdirectory READMEs contain the actual startup commands and implementation details.
