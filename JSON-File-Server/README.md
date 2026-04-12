# Authentication and Authorization Example

## Overview

This example shows how to enable both authentication and authorization with an Access Control List (ACL). It uses the BAS [JSON Authenticator](https://realtimelogic.com/ba/doc/en/lua/lua.html#ba_create_jsonuser), which can authenticate users and optionally authorize access based on:

- the authenticated user
- a predefined set of URIs
- the HTTP method used

The example applies that combined authenticator and authorizer to a [File Server object](https://realtimelogic.com/ba/doc/en/lua/lua.html#ba_create_wfs), so the same setup protects both the Web File Manager and WebDAV access.

Authentication and authorization serve different roles here:

- **Authentication** verifies who the user is.
- **Authorization** decides which resources that user may access after logging in.

The JSON authenticator is convenient because it supports both concerns in one BAS-native setup.

The same JSON-based authenticator is not limited to file servers. It can also be used in ordinary BAS applications when you want an easy way to define users and optional authorization constraints without building a custom user store first.

## Files

- `www/.preload` - Creates the file server, user database, optional authorizer, and ACL rules.
- `www/index.lsp` - Lets you access the file server through digest authentication or test programmatic login through `request:login()`.
- `www/logout.lsp` - Handles logout behavior and shows the relevant logout notes.
- `mako.conf` - Optional configuration flag used to disable the authorizer for testing.

## How to run

Start the example with the Mako Server:

```bash
cd JSON-File-Server
mako -l::www
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

After the server starts, open `http://localhost:portno`, where `portno` is the HTTP port shown in the console.

Hardcoded users:

| Username | Password |
| --- | --- |
| `guest` | `guest` |
| `kids` | `kids` |
| `mom` | `mom` |
| `dad` | `dad` |

On the page, you can:

- open `fs/` and log in through HTTP Digest authentication
- use `request:login()` to test programmatic authentication

To test the version without an authorizer, stop the server, edit `mako.conf`, remove the comment that disables the authorizer, and restart the app.

## How it works

`www/.preload` creates a writable root for the file server, mounts a WebDAV/Web File Manager instance at `/fs/`, builds a JSON-backed user database, and optionally creates an authorizer with path- and method-based constraints. If the authorizer is enabled, the ACL restricts write access and family-directory access according to the configured roles.

`index.lsp` demonstrates two different flows:

- regular HTTP Digest authentication against the mounted file server
- server-side login with [`request:login()`](https://realtimelogic.com/ba/doc/en/lua/lua.html#request_login)

That second flow is useful when the actual authentication source is not one of the built-in HTTP browser mechanisms, for example when integrating SSO or WebAuthn.

### Digest authentication and `request:login()`

The file-server side of the example uses **HTTP Digest Authentication**, which means the browser shows its own login dialog. `index.lsp` also demonstrates `request:login()` as a server-side API. With an authorizer enabled, `request:login()` must identify a user the authorizer recognizes. The page lets you try valid users, `nil`, and unregistered usernames so you can see how the authorizer changes the outcome.

### ACL setup

The ACL rules in `.preload` cover:

- read-only guest access
- shared family access
- role-specific access for `mom` and `dad`
- separate child access under `/family/kids/`

This makes the example useful both as a file-server demo and as a concrete ACL pattern you can adapt.

### Included users and roles

The demo keeps the user database simple on purpose. Each user's password is the same as the username, and each user receives a role set that makes the ACL behavior easy to test:

- `guest` has guest access
- `kids` adds family access
- `dad` and `mom` add parent-specific roles and writable areas

This lets you test both the authentication flow and the role-based authorization flow without any external setup.

The example also doubles as a concrete reminder that `request:login()` is a BAS login API, not just a file-server helper. That is why this README points to SSO and WebAuthn as natural follow-on examples.

## Notes / Troubleshooting

- Browsers cache Digest credentials aggressively. In some cases you must fully close the browser before you can test a different Digest user cleanly.
- With an authorizer installed, `request:login()` must identify a user that the authorizer recognizes. Without an authorizer, the file server can be opened more freely for testing.
- For broader WebDAV background, see [How to Create a Cloud Storage Server](https://makoserver.net/articles/How-to-Create-a-Cloud-Storage-Server).
- `logout.lsp` can only do a full logout for the programmatic-login flow. Digest credentials are still controlled by the browser.
- The authorizer toggle in `mako.conf` is there specifically so you can compare plain authentication behavior with full role-based authorization behavior.
- That side-by-side comparison is intentional.
