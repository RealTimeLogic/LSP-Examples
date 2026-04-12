# REST / AJAX / RPC Over SMQ

## Overview

This example provides ready-to-use client-side and server-side libraries for REST-, AJAX-, and RPC-style communication over SMQ. From the browser, you call server functions asynchronously and receive responses without reloading the page.

Although the example uses an RPC-style programming model, the practical interaction pattern is the same one you already know from AJAX and many REST APIs:

- the client sends a request
- the server performs some work
- the client receives a result asynchronously

SMQ simply provides a lower-overhead bidirectional transport for that pattern.

A few terminology notes help frame the example:

- **AJAX** describes background browser requests
- **REST** and **RPC** describe how the API itself is modeled
- the runtime behavior is still asynchronous request/response handling

### What is SMQ?

[SMQ](https://realtimelogic.com/products/simplemq/) is a lightweight, message-based communication layer designed for low-latency, bidirectional messaging between browsers and servers. It avoids repeated HTTP request overhead and is well suited for interactive applications where responsiveness matters.

That is why it maps well to RPC-style browser calls. If your browser already needs an SMQ connection for live updates or publish/subscribe traffic, adding method-call support on top of the same connection is often simpler than maintaining a second HTTP API just for request/response operations.

## Files

- `.preload` - Starts the SMQ broker, registers a few basic one-to-one demo messages, mounts the broker at `/smq`, and exposes the RPC interface.
- `.lua/smqrpc.lua` - Server-side SMQ RPC helper that dispatches `$RpcReq` messages and publishes `$RpcResp` replies.
- `smqrpc.js` - Client-side library that creates an RPC proxy on top of an SMQ client.
- `index.html` - Browser example that exercises the RPC library.

## How to run

Start the example with the Mako Server:

```bash
cd LSP-Examples/SMQ-examples
mako -l::RPC
```

## How it works

The startup script creates an SMQ broker and exposes it through a BAS directory function mounted at `/smq`. It then registers an RPC interface table with three example methods:

- `echo(...)`
- `multiply(a, b)`
- `failfunc()`

On the server side, `.lua/smqrpc.lua` listens for `$RpcReq` messages sent to `self`, looks up the requested function name in the interface table, runs it with `pcall(...)`, and publishes the result or error back to the calling client as `$RpcResp`.

The server-side helper stays deliberately small. Its job is to translate one incoming SMQ request into one Lua function call and one SMQ response message. That keeps the flow easy to study and easy to reuse in other apps.

### Server-side pattern

The server interface is just a Lua table:

```lua
local interface = {
   echo=function(...) return {...} end,
   multiply=function(a,b) return a * b end,
   failfunc=function() return nil, "this function fails" end
}

require"smqrpc".create(smq, interface)
```

Each function exposed in that table becomes callable from the browser.

On the client side, `smqrpc.js` turns those message exchanges into Promise-based method calls, so browser code can use either `.then(...)` or `async` / `await`.

### Client-side usage pattern

The JavaScript helper creates a proxy object from an existing `smq` client:

```javascript
let smqRpc = createSmqRpc(smq);
const rpc = smqRpc.proxy;

smq.onclose = () => {
    smqRpc.disconnect();
};
```

Each RPC call returns a Promise, so both of the following styles work:

```javascript
rpc.multiply(3, 7)
   .then(response => console.log(response))
   .catch(error => console.error(error));
```

```javascript
async function demo() {
   try {
      const value = await rpc.multiply(3, 7);
      console.log(value);
   } catch (error) {
      console.error(error);
   }
}
```

That makes the client code feel close to a normal REST or AJAX call while still using SMQ for transport.

The advantage is that one SMQ connection can now support both publish/subscribe messaging and request/response style browser calls.

The original tutorial also frames this as the SMQ equivalent of the AJAX-over-WebSockets pattern: the transport changes, but the application idea stays the same.

If you need to send very large payloads, use LSP pages or the [REST plugin](https://realtimelogic.com/articles/Designing-RESTful-Services-in-Lua) instead. SMQ is designed for messaging, and a recommended upper bound for this RPC layer is roughly 65,400 bytes per message.

## Notes / Troubleshooting

- If the SMQ connection closes, make sure your client calls the library's disconnect handling so pending RPC Promises do not hang.
- From a high-level point of view, this example follows the same request/response idea as the AJAX-over-WebSockets example, but uses SMQ instead of raw WebSockets.
- Related example: [AJAX over WebSockets](../../AJAX-Over-WebSockets/README.md)
- If you are new to SMQ, read the sibling `one2one/` example first and then come back to this RPC layer.
