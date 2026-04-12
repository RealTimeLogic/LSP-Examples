# SMQ Controlled Light Switch

## Overview

This example accompanies the tutorial [Modern Approach to Embedding a Web Server in a Device](https://realtimelogic.com/articles/Modern-Approach-to-Embedding-a-Web-Server-in-a-Device). It includes a browser-based light switch UI and a matching light bulb UI that communicate through SMQ.

## Files

- `www/switch.html` - Browser-based switch application.
- `www/bulb.html` - Browser-based bulb application.
- `www/smq.lsp` - Local SMQ broker endpoint used when you run the example with Mako Server.
- `www/switch.css` and `www/bulb.css` - Styling for the two browser pages.

## How to run

You can use the HTML files directly by dragging them into a browser without running a server. In that mode they use the hosted SimpleMQ service.

To run everything locally instead:

1. Open `switch.html` and `bulb.html` in an editor.
2. In both files, replace:

```javascript
var smq = SMQ.Client("wss://simplemq.com/smq.lsp");
```

with:

```javascript
var smq = SMQ.Client("ws://localhost/smq.lsp");
```

3. Start Mako Server in this directory:

```bash
mako -l::www
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

4. Drag and drop the modified `switch.html` and `bulb.html` into browser windows to connect to your local broker.

## How it works

The switch page publishes state changes over SMQ, and the bulb page subscribes to the same channel so it can react visually. The local `smq.lsp` file provides the broker endpoint when you want to test the entire flow on your own machine instead of against the hosted test service.

## Notes / Troubleshooting

- SMQ documentation: https://realtimelogic.com/ba/doc/?url=SMQ.html
- SMQ tutorials: https://makoserver.net/tutorials/
- The [SMQ repository includes a C and C++ light bulb implementation](https://github.com/RealTimeLogic/SMQ#2-light-bulb-example) that can also be controlled by `switch.html`.
