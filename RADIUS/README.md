# RADIUS Authentication

This tutorial shows you how to integrate RADIUS authentication into your web application using Lua. You'll build a custom RADIUS client module and wire it into your application's startup script (`.preload` ) to enable centralized, external user validation.

**Note:** This example is a copy of the [LSP-Examples/authentication/root]([../../../authentication/README.md#example-root) example, with RADIUS integration modifications. We recommend starting with this example, as it includes introductory authentication information.

* * *

## What is RADIUS?

**RADIUS** (Remote Authentication Dial-In User Service) is a lightweight, UDP-based protocol designed for centralized authentication, authorization, and accounting. It's used in enterprise networks, VPNs, and wireless infrastructure, and embedded devices and custom applications that need to delegate authentication securely.

When a user logs in, your application sends a RADIUS `Access-Request` to a centralized server, which replies with:

- `Access-Accept` : login success

- `Access-Reject` : login failed

- `Access-Challenge` : more input required (not used in this tutorial)


In this setup, the app becomes a **RADIUS client** \- sending login credentials to the RADIUS server, validating the response, and controlling access accordingly.

* * *

## ⚙️ Setting Up a Local RADIUS Server (FreeRADIUS on Linux or WSL)

If you want to test the Lua RADIUS client locally, the easiest option is to use **FreeRADIUS** on a Linux system or Windows Subsystem for Linux (WSL).

### ✅ Step-by-Step Setup

```bash
# Step 1: Install FreeRADIUS
sudo apt update
sudo apt install freeradius

# Step 2: Add a test user
sudo nano /etc/freeradius/3.0/users
```

Add this line at the top:

```text
testuser Cleartext-Password := "testpass"
```

Save and exit the Nano editor.

```bash
# Step 3: Allow your Lua client to talk to FreeRADIUS
sudo nano /etc/freeradius/3.0/clients.conf
```

Add this block:

```ini
client localhost {
    ipaddr = 127.0.0.1
    secret = myradiussecret
}
```

🔒 Make sure the `secret` matches the value used in your Lua `.preload` file.

```bash
# Step 4: Start the server in debug mode
sudo freeradius -X
```

You should see:

```text
Ready to process requests
```

At this point, your Mako Server can authenticate users via RADIUS using:

- Username: `testuser`

- Password: `testpass`

- Shared secret: `myradiussecret`

- Server IP: `127.0.0.1`

- Port: `1812`

**Note:** The above settings can be found in [www/.preload](www/.preload)

* * *

## ✅ Next Step

Once the RADIUS server is running, launch the mako Server.

``` bash
cd LSP-Examples/RADIUS
mako -l::www
```

For detailed instructions on starting the Mako Server, check out our
[command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and review
the server\'s [command line
options](https://realtimelogic.com/ba/doc/en/Mako.html#loadapp) in our
documentation.

The `.preload` script will use the RADIUS Lua module to send credentials to the RADIUS server and process the reply. Authentication succeeds only if the server returns a valid, hash-verified `Access-Accept` response.

After starting the Mako Server, open your browser and navigate to: `http://localhost`

Log in using the following test credentials:

- **Username**: `testuser`

- **Password**: `testpass`


The server-side authenticator uses **form-based authentication** when accessed via a browser. However, **HTTP Basic authentication** is also supported and can be useful for API clients (machine-to-machine).

To test basic authentication using `curl` , run:

```bash
curl -i -u "testuser:testpass" http://localhost
```


## The application's `.preload`

The [www/.preload](www/.preload) script integrates a **RADIUS-based login mechanism** into the web application. It:

- Loads a custom Lua RADIUS client module and configures it with server connection info.

- Implements a `getpassword()` callback that delegates username/password authentication to the RADIUS server.

- Sets up a custom login response handler ( `loginresponse` ) to manage redirects and error pages for form-based logins.

- Creates a Mako `authuser` and `authenticator` instance using the callback and response handler.

- Applies the authenticator to the app's directory via `dir:setauth()` , effectively securing access behind RADIUS authentication.

## The RADIUS Lua Module

### require"radius".create(radiusServerIP, radiusServerPort, sharedSecret)

Creates and returns a RADIUS client instance configured to communicate with a specific RADIUS server.

#### **Parameters**

- radiusServerIP (string): IP address of the RADIUS server (e.g., "192.168.0.1" or "127.0.0.1").
- radiusServerPort (number): UDP port used by the RADIUS server (usually 1812).
- sharedSecret (string): The pre-shared secret is configured on both the client and server for authentication and hashing.

#### **Returns**

- A table representing a RADIUS client instance, with a login(username, password) method.

#### **Usage**

```lua
local rad = require"radius".create("127.0.0.1", 1812, "mysecret")
```

### rad:login(username, password)

Sends a RADIUS Access-Request packet to the configured server and waits (blocking) for a response.

#### **Parameters**

- username (string): The username to authenticate.
- password (string): The user's plaintext password.

#### **Returns**

- On success: true
- On failure: false, errorMessage

#### **Behavior**

- Internally builds the RADIUS packet with User-Name and User-Password attributes.
- Encodes the password using MD5 as specified by RFC 2865.
- Validates the server's response authenticator to ensure integrity.
- Blocks for up to 3 seconds while waiting for a server response.

#### **Usage**

```lua
local ok, err = rad:login("testuser", "testpass")
if ok then
   trace("Login successful!")
else
   trace("Login failed:", err)
end
```
