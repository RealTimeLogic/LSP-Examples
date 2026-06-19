# SMQ IoT Tutorials and Examples

## Overview

This directory contains the source code for the SMQ tutorials published at makoserver.net. The bundle covers three examples:

- [A basic chat client](https://makoserver.net/articles/Designing-a-browser-based-Chat-Client-using-SimpleMQ)
- [Improving the chat client](https://makoserver.net/articles/Improving-the-browser-based-Chat-Client)
- [Device LED control](https://makoserver.net/articles/Browser-to-Device-LED-Control-using-SimpleMQ)

## Files

- `www/.preload` - Starts the SMQ support used by the example bundle.
- `www/index.lsp` - Landing page for the bundled examples.
- `www/smq.lsp` - SMQ broker endpoint used by the browser examples.
- `www/chat/BasicChat.html` - Basic chat example.
- `www/chat/index.html` - Improved chat example.
- `www/led-control/index.html` - Device LED control example.
- `www/chat/` and `www/led-control/` assets - Supporting CSS and sound files used by the demos.

## How to run

Start the bundle with the Mako Server:

```bash
cd SMQ-examples/IoT
mako -l::www
```

After the server starts, open the HTTP URL printed in the Mako console.

## How it works

The browser examples all connect to the SMQ endpoint exposed by `smq.lsp`. The basic chat example uses publish/subscribe for shared messages. The improved chat example extends that design with one-to-one messaging so each client can maintain a user list and typing indicators. The LED-control example shows how the same SMQ messaging model can be used for device-management style user interfaces.

## Packaging for Xedge

This example can be packaged as an Xedge app by creating a ZIP from the `www/` directory, so the app files are at the ZIP root. See [Xedge App Deployment](../../Xedge-App-Deployment/README.md) for the detailed deployment workflow.

```bash
cd www
zip -D -q -u -r -9 ../smq-iot.zip .
```

Upload the generated ZIP with the Xedge App Upload tool.


## Notes / Troubleshooting

- For the LED example, the web interface will not show active devices until at least one SMQ device client connects to your broker.
- Open multiple browser windows when testing the chat examples so the publish/subscribe behavior is easier to see.
