# SMQ IoT Tutorials and Examples

## Overview

This directory contains the source code for the SMQ tutorials published at makoserver.net. The bundle covers three examples:

- [A basic chat client](https://makoserver.net/articles/Designing-a-browser-based-Chat-Client-using-SimpleMQ)
- [Improving the chat client](https://makoserver.net/articles/Improving-the-browser-based-Chat-Client)
- [Device LED control](https://makoserver.net/articles/Browser-to-Device-LED-Control-using-SimpleMQ)

## Files

- `.preload` - Starts the SMQ support used by the example bundle.
- `index.lsp` - Landing page for the bundled examples.
- `smq.lsp` - SMQ broker endpoint used by the browser examples.
- `chat/BasicChat.html` - Basic chat example.
- `chat/index.html` - Improved chat example.
- `led-control/index.html` - Device LED control example.
- `chat/` and `led-control/` assets - Supporting CSS and sound files used by the demos.

## How to run

Start the bundle with the Mako Server:

```bash
cd LSP-Examples/SMQ-examples
mako -l::IoT
```

After the server starts, open `http://localhost`.

## How it works

The browser examples all connect to the SMQ endpoint exposed by `smq.lsp`. The basic chat example uses publish/subscribe for shared messages. The improved chat example extends that design with one-to-one messaging so each client can maintain a user list and typing indicators. The LED-control example shows how the same SMQ messaging model can be used for device-management style user interfaces.

## Notes / Troubleshooting

- For the LED example, the web interface will not show active devices until at least one SMQ device client connects to your broker.
- Open multiple browser windows when testing the chat examples so the publish/subscribe behavior is easier to see.
