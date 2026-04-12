# One-to-One Communication

## Overview

This example demonstrates one-to-one communication between a browser and a server using the SMQ protocol. It focuses on the basics: how a browser subscribes to messages addressed specifically to itself and how it publishes messages back to the server.

## Files

- `.preload` - Starts the SMQ broker-side support used by the example.
- `index.html` - Browser-side example showing the one-to-one publish and subscribe flow.

## How to run

Start the example with the Mako Server:

```bash
cd LSP-Examples/SMQ-examples
mako -l::one2one
```

## How it works

The browser creates an SMQ client with a clean start so each connection begins without retained local state. It then subscribes to messages addressed to `self`, which lets the server send one-to-one replies back to that specific browser instance. After the subscription is in place, the client publishes JSON messages to the broker to complete the round trip.

## Notes / Troubleshooting

- This example is a good foundation for the more advanced SMQ RPC example in the sibling `RPC/` directory.
- See the [SMQ documentation](https://realtimelogic.com/ba/doc/?url=SMQ.html) if you want a deeper explanation of subtopics and topic addressing.
