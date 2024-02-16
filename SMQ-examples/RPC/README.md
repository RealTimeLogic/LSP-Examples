# RPC (aka AJAX) over SMQ
## Call server methods from browser

This example includes ready-to-use client-side and server-side libraries for performing RPC over SMQ. The code enables super fast and easy server-side method calls from a browser.

Remote Procedure Calls (RPC) and AJAX are both technologies used for communication between a client (such as a web browser) and a server, enabling the client to request data or services from the server without needing to reload the page. Despite their different names, they share the same fundamental concept: both are methods for making calls to a server in a way that is decoupled from the main program flow, allowing for asynchronous interactions.


## Client-Side SMQ RPC Library (`smqrpc.js`)

This JavaScript library provides a simple way to perform Remote Procedure Calls (RPC) over SMQ. It abstracts the complexity of sending and receiving messages, allowing for asynchronous function calls to the server.

### Features

- **Dynamic Proxy Creation**: Automatically generates proxies for making remote procedure calls.
- **Asynchronous Communication**: Utilizes Promises for non-blocking operations.
- **Error Handling**: Supports robust error handling for failed RPC calls.

### Usage

To use the library, you need an `smq` object configured for your SMQ messaging environment. Pass this object to the `createSmqRpc` function to initialize the RPC mechanism.

### Initialization

```javascript
let smq = {/* Your SMQ configuration here */};
let smqRpc = createSmqRpc(smq);
-- smqRpc includes proxy and disconnect().
var rpc=smqRpc.proxy;
smq.onclose = () => {
   smqRpc.disconnect(); // Sends the promise:reject to all pending commands.
};
```

## Invoke methods on the rpc.proxy object to make RPC calls. Each call returns a Promise.

```javascript
rpc.yourMethodName("Hello", "World").then(response => {
    console.log('Response:', response);
}).catch(error => {
    console.error('RPC Error:', error);
});
```

## Server-Side SMQ RPC Library (`smqrpc.lua`)

The Lua library for handling server-side logic of RPC over SMQ. It complements the client-side JavaScript library, processing RPC requests received from clients and responding accordingly.

```lua
-- Define a function that corresponds to 'yourMethodName'
function yourMethodName(arg1, arg2)
    -- Implement the logic you want to execute when
    -- 'yourMethodName' is called from the client
    trace("yourMethodName called with arguments:", arg1, arg2)
    -- For illustration, let's just concatenate the arguments and return the result
    local result = arg1 .. " " .. arg2
    return result -- "Hello World"
end

smq=require"smq.hub".create()
require"smqrpc".create(smq, {yourMethodName=yourMethodName})
```

## Running the Example

Start the example, using the Mako Server, as follows:

```
cd LSP-Examples/SMQ-examples
mako -l::RPC 
```

## Files

```
|   .preload - Server example code
|   index.html - Client example code
|   smqrpc.js - Client RPC library
|
\---.lua
        smqrpc.lua - Server RPC library
```
