# Manual DNS-01 Certificate Application

This example shows how to obtain and renew a TLS certificate when DNS records
must be updated manually. The browser displays the DNS TXT record required by
the ACME service, waits for an operator to publish it, and resumes certificate
validation after the operator confirms the change.

The application has two distinct parts:

- [`manual.lua`](www/.lua/manual.lua) is a reusable BAS Lua/LSP component. It
  does not assume that the host is Mako Server.
- [`.preload`](www/.preload) is the Mako-specific bootstrap. It loads
  `mako.conf`, creates the ACME runtime, and starts it. Mako selects its
  writable `home` I/O and standard certificate installer automatically.

The application never creates or removes DNS records. The TXT record may remain
in DNS after validation.

## Quick Start with Mako Server

Add the following application-specific settings to a private `mako.conf`
outside `www`. If you use the supplied template, remove its initial
`if true then return end` line after completing the settings:

```lua
-- Accept the provider's terms before enabling certificate requests.
manualDns = {
   acceptTerms = true,
   email = "operator@example.com",
   domains = {"device.example.com"},
   production = false
}
```

Keep `production = false` while learning or testing. This selects the Let's
Encrypt staging service and avoids production rate limits. Change it to `true`
only when you are ready to request a trusted production certificate.

Run Mako from the directory containing `mako.conf`:

```bash
mako -l::www
```

Then open `http://localhost/` (or the port configured in `mako.conf`).
The same Mako process must have an HTTPS listener enabled to install the
certificate. Keep its writable `homeio` separate from the other examples.

The Mako bootstrap reads `manualDns` with `local conf=require"loadconf"`. It
creates the manual DNS-01 challenge adapter, initializes `manual.lua`, and
starts certificate management. The runtime uses Mako's `home` I/O.

## Tutorial: Complete a Manual DNS-01 Challenge

1. Start the application with a domain whose authoritative DNS records you can
   edit.
2. Wait for the page to display a TXT record name and value.
3. Add that exact TXT record at your DNS provider. Do not alter or decode the
   value.
4. Wait until a public DNS lookup returns the new value.
5. Select **I have published the TXT record**.
6. The ACME service validates the record and issues the certificate.
7. Wait for the page to report **Certificate installed** and show the expiry
   date.

The certificate is now managed by the ACME runtime. To exercise the workflow
again, select **Request new certificate**. A certificate authority may reuse
a recent domain authorization and skip the TXT step. Use a fresh domain you
control when you need to test publication from the beginning. The installed certificate remains in
use until its replacement has been issued successfully.

If you no longer want to continue a pending challenge, select **Cancel**. This
stops the current manual step, but it does not remove the TXT record from DNS.

## How the Application Works

The browser polls [`status.lsp`](www/status.lsp) for read-only state. When the
ACME engine reaches a DNS-01 challenge, the manual challenge adapter pauses and
provides the required TXT record through `challenge:status()` and that status
endpoint. Progress messages are selected by the browser from the phase; the
ACME adapter no longer supplies a message or a notification event table.
Its notification callback receives integer code 32 when publication is needed.

Operator commands are sent as URL-encoded POST requests to
[`action.lsp`](www/action.lsp). The endpoint checks authorization and a
session-bound request token before accepting a command. The continue and cancel
requests use a deferred response because the challenge callback completes
asynchronously. The response is sent only after the ACME runtime has accepted
the requested transition.

The sequence is:

1. The host creates and starts an ACME runtime.
2. The runtime asks the manual adapter to present a DNS-01 challenge.
3. The adapter pauses and exposes the TXT name and value.
4. The operator publishes the record and confirms it in the browser.
5. The adapter resumes the ACME operation.
6. The ACME service validates DNS and issues the certificate.
7. The host installs the certificate and the page reports completion.

## Using `manual.lua` Without Mako Server

`manual.lua` can run in another BAS Lua/LSP host. It is not a standalone module
for a generic Lua interpreter because it uses BAS request, response, session,
and application APIs.

The host must:

- select a private writable IO and the appropriate certificate installer;
- create, start, and close the ACME runtime;
- initialize `manual.lua` before serving its LSP endpoints; and
- protect remote management access with an authenticator.

A typical host bootstrap looks like this:

```lua
local Runtime=require"acme/runtime"
local manual=appreq"manual"

-- The host owns the runtime and closes it during application unload.
local runtime,err=Runtime.create{
   io=writableIo,
   install=installCertificates,
   config={
      acceptTerms=true,
      email="operator@example.com",
      domains={"device.example.com"},
      production=false,
      challenge={type="dns-01",mode="manual"}
   }
}
assert(runtime,err and (err.message or err.code))

manual.init(runtime)
runtime:start(function(_,problem)
   if problem then
      trace("ACME startup failed: ",problem.message or problem.code)
   end
end)

function onunload()
   runtime:close()
end
```

In this example, `writableIo` and `installCertificates` are supplied by the
standalone host. ACME state is stored in the `acme/` directory relative to that
I/O. Do not select a read-only ZIP I/O. The installer must activate the complete
certificate set and invoke its callback when activation finishes.

The example's [`status.lsp`](www/status.lsp) and
[`action.lsp`](www/action.lsp) files can be used unchanged when the application
is installed under another BAS host.

## `manual.lua` API

### `manual.init(runtime)`

Initializes the component with an ACME runtime. Call it once before the status
or action endpoints can be used. Pass the successful result from
`Runtime.create()` configured with `challenge={type="dns-01",mode="manual"}`,
as shown above.
`manual.init()` does not start or close the runtime.

### `manual.status(request,response)`

Handles a `GET` request and sends the current state as JSON. It is normally
called by `status.lsp`:

```lua
local manual=app.appreq"manual"
return manual.status(request,response)
```

The response is a JSON object with these fields when applicable. TXT strings
are present only while publication is pending; optional fields may be absent:

| Field | Description |
| --- | --- |
| `ok` (boolean) | `true` when the status request succeeded. |
| `configured` (boolean) | `true` after `manual.init(runtime)`. |
| `manual` (boolean) | `true` when the runtime uses the manual challenge adapter. |
| `phase` (string) | `idle`, `publish`, `active`, or `unavailable`. |
| `recordName` (string) | DNS TXT record name during the `publish` phase. |
| `recordData` (string) | DNS TXT record value during the `publish` phase. |
| `operation` (string) | Current ACME operation. |
| `starting` (boolean) | `true` while the runtime is starting. |
| `retryPending` (boolean) | `true` when a retry has been scheduled. |
| `directoryUrl` (string) | Selected ACME directory URL. |
| `domains` (array) | Certificate records with `name` (string), optional `expiresAt` and `renewAt` (Unix seconds). |
| `ready` (boolean) | `true` when certificate management is ready. |
| `error` (string) | Current error message or code, if any. |
| `access` (string) | `authenticated`, `local`, or `read-only`. |
| `canManage` (boolean) | `true` when the caller may send actions. |
| `csrf` (string) | Session request token, returned only to an authorized caller. |

Status is deliberately read-only, so the page can report certificate state
through the issued domain without granting management access.

### `manual.action(request,response)`

Handles a URL-encoded `POST` request containing required string fields
`action` and `csrf`. It
is normally called by `action.lsp`:

```lua
local manual=app.appreq"manual"
return manual.action(request,response)
```

Supported actions are:

| Action | When accepted | Result |
| --- | --- | --- |
| `continue` | A challenge is waiting in the `publish` phase. | Resumes validation after the TXT record has been published. |
| `cancel` | A challenge is waiting in the `publish` phase. | Cancels the pending manual step. |
| `renew` | The runtime is ready and has a configured domain. | Starts a new certificate request for the first domain. |

`continue` and `cancel` keep a deferred response object until the challenge
callback completes. Successful completion returns HTTP 200. `renew` is accepted
immediately with HTTP 202 because renewal continues in the background.

The endpoint rejects unsupported methods, oversized requests, invalid content
types, unauthorized callers, invalid request tokens, and actions that do not
match the current state. Error responses use HTTP 400, 401, 403, 405, 409, 413,
or 415 as appropriate.

## Access Control

A request may change state when either condition is true:

- `request:user()` identifies an authenticated user; or
- the request originates from the local computer.

Other callers receive read-only status and cannot obtain the session request
token. For a remote deployment, protect the entire application with the BAS
host's normal directory authenticator.

## Application Files

| File | Purpose |
| --- | --- |
| [`www/.preload`](www/.preload) | Mako-specific configuration, IO selection, startup, and shutdown. |
| [`www/.lua/manual.lua`](www/.lua/manual.lua) | Reusable status and action component. |
| [`www/status.lsp`](www/status.lsp) | Read-only JSON status endpoint. |
| [`www/action.lsp`](www/action.lsp) | Authorized POST action endpoint. |
| [`www/app.js`](www/app.js) | Browser workflow and status polling. |
| [`www/index.lsp`](www/index.lsp) | Operator interface. |
