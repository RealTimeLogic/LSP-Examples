# RADIUS Authentication

## Overview

This example shows how to integrate RADIUS authentication into a BAS web application by building a small Lua RADIUS client and wiring it into the application's startup script. It is based on the `authentication/root` example, with the authentication callback replaced by a RADIUS-backed implementation.

RADIUS is a lightweight UDP-based protocol commonly used for centralized authentication, authorization, and accounting. In this example, the BAS application acts as the RADIUS client and delegates username/password validation to a RADIUS server.

When a user logs in, the application sends a RADIUS `Access-Request` packet and then waits for one of the standard outcomes:

- `Access-Accept`
- `Access-Reject`
- `Access-Challenge` (not used by this demo)

## Files

- `www/.preload` - Configures the RADIUS client, creates the BAS authenticator, and applies it to the application directory.
- `www/.lua/radius.lua` - Lua RADIUS client module.
- `www/index.lsp` - Protected landing page shown after a successful login.
- `www/.login/form.lsp` and `www/.login/failed.lsp` - Form-based login UI and failure page.
- `www/public/` - Public static assets for the login flow.

## How to run

To test locally, one simple option is FreeRADIUS on Linux or WSL:

1. Install FreeRADIUS:

```bash
sudo apt update
sudo apt install freeradius
```

2. Add a test user to `/etc/freeradius/3.0/users`:

```text
testuser Cleartext-Password := "testpass"
```

3. Allow the BAS client to talk to FreeRADIUS by adding this block to `/etc/freeradius/3.0/clients.conf`:

```ini
client localhost {
    ipaddr = 127.0.0.1
    secret = myradiussecret
}
```

4. Start FreeRADIUS in debug mode:

```bash
sudo freeradius -X
```

5. Start the BAS example:

```bash
cd LSP-Examples/RADIUS
mako -l::www
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/en/Mako.html#loadapp).

Then open `http://localhost` and log in with:

- Username: `testuser`
- Password: `testpass`

HTTP Basic authentication is also supported. You can test it with:

```bash
curl -i -u "testuser:testpass" http://localhost
```

## How it works

`www/.preload` creates a RADIUS client with:

```lua
local rad = require"radius".create("127.0.0.1", 1812, "myradiussecret")
```

The authenticator's password callback forwards the submitted username and password to `rad:login(...)`. If the RADIUS server returns `Access-Accept`, the BAS authenticator treats the login as successful; otherwise the login fails and the normal BAS response handler sends the user to the failure flow.

Inside `www/.lua/radius.lua`, the module:

- builds the RADIUS Access-Request packet
- obfuscates the password according to the RADIUS protocol
- sends the packet over UDP
- waits for the response
- validates the response authenticator before accepting the result

### `require"radius".create(radiusServerIP, radiusServerPort, sharedSecret)`

This function creates the RADIUS client instance. The parameters are:

- `radiusServerIP` - IP address of the RADIUS server
- `radiusServerPort` - UDP port, normally `1812`
- `sharedSecret` - pre-shared secret configured on both client and server

The returned object provides `rad:login(username, password)`, which performs a blocking authentication round trip and returns either `true` or `false, err`.

### `rad:login(username, password)`

`rad:login(...)` sends one Access-Request packet to the configured server and then waits for the reply. In this example, the method:

- builds the `User-Name` and `User-Password` AVPs
- encodes the password using the MD5-based scheme defined by RFC 2865
- sends the packet over UDP
- waits for the response
- accepts the login only when the response code and authenticator both validate

That makes the BAS side a thin client for the centralized RADIUS service rather than a separate password database.

### What `.preload` sets up

The `.preload` file does five important things:

- loads the custom Lua RADIUS client
- creates the BAS `authuser` callback around it
- configures the login-response flow for form-based login
- creates the BAS authenticator
- applies the authenticator to the application directory with `dir:setauth()`

## Notes / Troubleshooting

- The shared secret in `www/.preload` must match the `secret` configured in FreeRADIUS.
- This example supports form-based and basic-style flows, but digest authentication is not supported by the RADIUS callback setup used here.
- The current Lua RADIUS module logs credentials through `trace(...)`, which is a security issue in real deployments. I did not change the code, but you should remove that logging before using the module outside a demo environment.
- This example is easiest to understand if you first review the generic [authentication](../authentication/README.md) examples, because the BAS authenticator flow is the same and only the password backend changes.
- The demo server settings are intentionally visible in `.preload` so you can quickly point the example at a different RADIUS server during testing.
