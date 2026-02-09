# REST / AJAX / RPC - different names, same idea
## Call server methods from the browser

This example includes ready-to-use client-side and server-side libraries for performing **REST / AJAX / RPC-style communication over SMQ**. The code enables fast and simple server-side method calls directly from a browser, without page reloads.

At a conceptual level, **REST**, **AJAX**, and **RPC (Remote Procedure Calls)** all describe ways for a browser to talk to a server **asynchronously**. The names come from different eras and communities, but the underlying idea is the same: the client sends a request, the server performs some work, and the result is returned without blocking the user interface.

In short:

- **AJAX** describes *how* the browser sends requests (background, asynchronous)
- **REST** and **RPC** describe *how the API is modeled*
- The runtime behavior is essentially the same

### A note on terminology

Although this example uses an **RPC-style programming model** (calling named server methods), it fulfills the same role as REST APIs in practice. Many real-world REST APIs are effectively RPC expressed through URLs and HTTP verbs. The difference here is primarily one of *expression*, not capability.

### What is SMQ?

[SMQ](https://realtimelogic.com/products/simplemq/) is a lightweight, message-based communication layer designed for low-latency, bidirectional messaging between browsers and servers. It avoids HTTP request overhead and is well suited for interactive applications where responsiveness matters.

### How the SMQ RPC Library Works

From a high-level perspective, the SMQ RPC plugin follows the same fundamental approach described in the [AJAX over WebSockets tutorial](https://makoserver.net/articles/AJAX-over-WebSockets), but uses SMQ instead of raw WebSockets. With SMQ, you get both asynchronous publish/subscribe messaging and AJAX-style method calls from the browser to the server, all within a single, unified communication model.

---

## REST / RPC over SMQ

**Call server methods directly from the browser.**

This example demonstrates REST/RPC-style communication over **SMQ** using client- and server-side libraries. From JavaScript, you call server functions as if they were local methods. Under the hood, the calls are sent asynchronously to the server, and results are returned without blocking the UI.

The result is:

- Very fast request/response handling (faster than HTTP-based REST)
- Simple, readable client code
- No conceptual difference from REST or AJAX-based APIs, just a more direct programming model

If you are comfortable with REST or AJAX, RPC over SMQ will feel familiar. It is the same interaction pattern, expressed in a way that emphasizes *calling server logic* rather than *manipulating URLs*.

---

## Client-Side SMQ RPC Library (`smqrpc.js`)

This JavaScript library provides a simple way to perform RPC-style calls over SMQ. It abstracts message handling and exposes server-side functions as asynchronous JavaScript methods.

### Features

- **Dynamic proxy creation**: Automatically generates proxies for remote procedure calls
- **Asynchronous communication**: Uses Promises for non-blocking operations
- **Error handling**: Clean propagation of server-side and connection errors

### Usage

To use the library, you need an `smq` object configured for your SMQ messaging environment. Pass this object to `createSmqRpc` to initialize the RPC mechanism.

### Initialization

```javascript
let smq = {/* Your SMQ configuration here */};
let smqRpc = createSmqRpc(smq);

// smqRpc includes: proxy and disconnect()
const rpc = smqRpc.proxy;

smq.onclose = () => {
    // Rejects all pending RPC calls so callers do not hang
    smqRpc.disconnect();
};
```

---

## Calling server methods

Each RPC call returns a **Promise**.

### Using Promises directly

```javascript
rpc.yourMethodName("Hello", "World")
    .then(response => {
        console.log("Response:", response);
    })
    .catch(error => {
        console.error("RPC Error:", error);
    });
```

### Using async / await (recommended)

```javascript
async function example() {
    try {
        const response = await rpc.yourMethodName("Hello", "World");
        console.log("Response:", response);
    } catch (error) {
        console.error("RPC Error:", error);
    }
}

example();
```

Both styles are functionally identical. `async / await` is simply modern syntax built on top of Promises and is often easier to read as applications grow.

---

## Server-Side SMQ RPC Library (`smqrpc.lua`)

The Lua library handles server-side RPC logic. Functions registered here are exposed automatically to connected clients.

```lua
-- Define a function that corresponds to 'yourMethodName'
function yourMethodName(arg1, arg2)
    trace("yourMethodName called with arguments:", arg1, arg2)

    -- For illustration, concatenate the arguments
    local result = arg1 .. " " .. arg2
    return result -- "Hello World"
end

smq = require "smq.hub".create()
require "smqrpc".create(smq, {
    yourMethodName = yourMethodName
})
```

---

## Running the example

Start the example using the Mako Server:

```
cd LSP-Examples/SMQ-examples
mako -l::RPC
```

---

## Files

```
|   .preload        - Server example code
|   index.html      - Client example code
|   smqrpc.js       - Client RPC library
|
\---.lua
        smqrpc.lua  - Server RPC library
```
