# Easy CSRF Prevention Using the `Referer` Header

## Overview

This example shows how to reduce the risk of Cross-Site Request Forgery (CSRF) by combining a trusted handshake with validation of the browser's `Referer` header. It is designed primarily for local or Intranet-style deployments, where the application needs to discover the server's effective host name at runtime instead of assuming a fixed IP address or DNS name.

The example also demonstrates an encrypted CSRF token for the initial handshake. That token is mainly used to discover the server name dynamically, but the same token mechanism can also be used more broadly for CSRF protection if you choose.

## Files

- `.preload` - Provides the helper logic used during the initial handshake, including token generation and server-name discovery.
- `index.lsp` - Starts the trusted handshake in the browser and redirects the user to the protected form page.
- `myapp/index.lsp` - Contains the form example that uses the discovered server name together with the `Referer` header check.

## How to run

Start the example with the Mako Server:

```bash
mako -l::CSRF-Prevention
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

## How it works

The first page the user visits is [`index.lsp`](index.lsp). That page performs a trusted handshake with help from the startup logic in [`.preload`](.preload). The server creates an encrypted token, stores the discovered server name, and sends the browser on to [`myapp/index.lsp`](myapp/index.lsp), where the form request can be checked against the expected host information.

The token itself is built with AES and JSON:

```lua
-- Create token
encryptedtoken = ba.aesencode(secret, ba.json.encode{time=ba.datetime"NOW":tostring()})

-- Decode token
token = ba.json.decode(ba.aesdecode(secret, encryptedtoken))
```

The embedded timestamp can be used on the server side to reject expired tokens. This is helpful during the initial handshake and can also be reused if you want token-based CSRF validation in additional flows.

Useful BAS references:

- [ba.aesencode](https://realtimelogic.com/ba/doc/?url=lua/lua.html#ba_aesencode)
- [ba.aesdecode](https://realtimelogic.com/ba/doc/?url=lua/lua.html#ba_aesdecode)
- [ba.json.encode](https://realtimelogic.com/ba/doc/?url=lua/lua.html#json_encode)
- [ba.json.decode](https://realtimelogic.com/ba/doc/?url=lua/lua.html#json_decode)
- [ba.datetime](https://realtimelogic.com/ba/doc/?url=lua/lua.html#ba_datetime)

## Notes / Troubleshooting

- This technique is especially useful when the server name can vary because of DNS, local naming, or services such as SharkTrustX.
- CSRF attacks are more common on public-facing systems, but internal systems still benefit from explicit request validation.
- If your deployment has multiple valid hostnames, make sure the handshake stores the hostname the browser actually used.
