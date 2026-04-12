# SMQ Cluster Example

## Overview

This example shows how to set up an SMQ testing cluster similar to the [online SMQ testing cluster](https://realtimelogic.com/IoT-LED-Cluster.html), but using only your own desktop computer. The purpose is to help you simulate a multi-node SMQ setup locally without requiring separate physical machines.

## Files

- `README.pdf` - Main walkthrough for the cluster example.
- `www/.preload` - Startup logic for the cluster app.
- `www/index.lsp` - Main cluster page.
- `www/autoconf.lsp` - Auto-configuration support used by the example.
- `www/smq.lsp` - SMQ broker endpoint.
- `www/chat/` - Chat example assets used within the cluster setup.

## How to run

Follow the setup instructions in the included [`README.pdf`](README.pdf), which contains the primary run and configuration details for this example.

## How it works

The app uses a local collection of SMQ endpoints and configuration pages to simulate several cluster participants on one machine. That lets you experiment with scale-out behavior, redundancy concepts, and clustered routing without first deploying to multiple hosts.

## Notes / Troubleshooting

- See the [online SMQ Cluster documentation](http://realtimelogic.com/ba/doc/?url=SMQ-Cluster.html) for the broader architectural background.
- The PDF is the authoritative walkthrough for this example directory.
