# Microsoft Entra ID SSO for a BAS File Server

This example uses OpenID Connect to authenticate users with Microsoft Entra ID
(formerly Azure AD), then protects a BAS Web File Server and WebDAV endpoint.
It includes a small **reusable** Lua module that can be copied into any Barracuda App
Server (BAS) powered product, including Mako Server and Xedge.

SSO lets a product rely on centrally managed organizational identities instead
of shipping product-local passwords. User access, account disabling, and login
policy remain under the organization's control rather than being duplicated on
every device or server.

## Microsoft's forced client secret rotation

This web application still needs a credential of its own.
Microsoft limits the lifetime of an app registration's client secret to [24
months or less](https://learn.microsoft.com/en-us/entra/identity-platform/how-to-add-credentials)
and recommends a lifetime shorter than 12 months. When that secret expires,
new logins cannot complete.

An enterprise application may have a dedicated security team to rotate its
credentials. A BAS-powered product, embedded device, or customer-managed VPS
often does not: the operator may have no command line or know how to edit the
server configuration. Rotation therefore needs an application-level workflow.

The reusable module reports upcoming expiration and credential failures through
callbacks. The Mako example in `www/.preload` turns those events into trace
messages and, when SMTP is configured, email notifications.

If Entra rejects an expired or invalid secret during a state-bound login, the
demo page in `www/index.lsp` presents a recovery form. The module activates a
replacement only after using it to complete a new authorization-code flow and
validating the resulting identity token. The detailed safeguards and
persistence boundary are described in [Browser-based secret
rotation](#browser-based-secret-rotation).

> For additional background, see [Single Sign On for Embedded
> Devices](https://www.linkedin.com/pulse/benefits-active-directory-single-sign-on-embedded)
> and the [Xedge authentication
> documentation](https://realtimelogic.com/ba/doc/en/Xedge.html#auth), which
> includes Microsoft Entra ID as a built-in SSO option.

## How the example is organized

- `www/.lua/ms-sso.lua` is the reusable OpenID Connect module. It has no Mako,
  filesystem, email, or persistence policy.
- `www/.preload` is the Mako integration example. It loads `mako.conf`, installs
  notification callbacks, and protects the Web File Server.
- `www/index.lsp` is the demo login page and provides the browser-based
  credential-recovery workflow.

Create the `mako.conf` described below and run Mako with `www` as the application
root. Other BAS products can reuse `ms-sso.lua` while replacing the Mako-specific
integration callbacks.

## Session URLs and WebDAV

After login, the demo page lets the user open Web File Manager or explicitly
generate a session URL for the WebDAV root. Web File Manager can also generate
a URL that starts at any displayed directory: select the directory, open its
context menu, and choose **Copy Session URL**.

A client that cannot perform browser SSO can use this URL as its credential.
For a quick test, paste it into a separate browser session that is not already
authenticated. You can also supply it directly to a WebDAV client.

### Mounting WebDAV

Use the session URL as the server URL when mounting or mapping the WebDAV
service. The [WebDAV mount tutorial](https://youtu.be/i5ubScGwUOc) demonstrates
the client-side procedure.

### Session URL security

A session URL is a bearer credential with the same file permissions as the BAS
session that created it. In this example it expires after two hours. Use HTTPS
outside localhost, keep the URL private, and never place it in logs, email,
analytics, or other systems that may retain it. Without HTTPS, anyone able to
intercept the URL can use it until it expires.

## Entra setup

The production registration described here belongs in the end customer's Entra
tenant. The product engineer normally creates a registration only in a
development tenant for testing. In a deployed product, responsibilities should
be divided as follows:

| Role | Responsibility |
| --- | --- |
| Product engineer | Integrate `ms-sso.lua`; provide secure initial provisioning, credential persistence, notification, and browser-based rotation in the BAS-powered product. |
| Customer Entra administrator or app-registration owner | Create and maintain the registration in the customer's tenant, create replacement secrets, and control redirect URIs and other registration settings. |
| Customer product administrator or operations team | Enter the customer-supplied settings into the product and monitor the credential notifications. In a smaller organization, this may be one of the app-registration owners. |

An **app-registration owner** is an individual account in the customer's Entra
tenant with administrative control over that registration. Owners are not the
ordinary users assigned permission to sign in. An owner can update the
registration's credentials and add or remove other owners, but that ownership
is scoped to the applications the person owns. See Microsoft's [application
registration owner
permissions](https://learn.microsoft.com/en-us/entra/fundamentals/users-default-permissions#application-registration-owner-permissions).

Choose the smallest practical set of active customer personnel, normally at
least two so credential rotation does not depend on one available person. Good
candidates are a member of the customer's identity/security team and the IT or
service owner responsible for the deployed product. Review the owner list when
responsibilities change or someone leaves the organization. A product-vendor
engineer should not be the customer's only owner or normal credential-rotation
path; document any exceptional vendor-managed arrangement explicitly.

The notification recipient is separate from Entra ownership. A product should
route the module's notification callback to a customer-managed, monitored
mailbox or ticketing address. In this Mako example, set `notify_to` to that
address. Make sure the recipients know which Entra owners can create a
replacement secret; assigning an owner in Entra does not configure the
notification callback.

For the single-tenant deployment used by this example, the customer's Entra
administrator or designated app-registration owner performs these steps in the
[Microsoft Entra admin center](https://entra.microsoft.com/):

1. Open **Entra ID > App registrations > New registration** and create a
   single-tenant application.
2. Under **Authentication**, add a **Web** redirect URI. It must exactly match
   `openid.redirect_uri` below. Use HTTPS except for localhost testing.
3. Under **Certificates & secrets**, create a client secret and immediately
   copy its **Value** and expiration date.
4. Under the app registration's **Owners**, assign the customer personnel who
   will be responsible for its credentials and configuration.
5. In the Enterprise Application, assign the intended users and enable
   **Assignment required** if access should be limited to assigned users.
6. Enter the tenant ID, client ID, client secret **Value**, and expiration date
   into the product's secure provisioning workflow. If another customer
   administrator performs this step, transfer the secret using the customer's
   approved secret-sharing method, not ordinary email or support tickets.

Microsoft documents the [authorization-code flow and
PKCE](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow)
and [adding an application
credential](https://learn.microsoft.com/en-us/entra/identity-platform/how-to-add-credentials).

## Testing the example with Mako

The `mako.conf` workflow below is for a product engineer testing this example.
It is not the recommended end-customer interface. A shipped BAS-powered product
should provide its own authenticated provisioning UI or installation workflow
and securely persist the customer-supplied values; the customer should not need
repository access or an SSH session.

In the following example, all settings except `notify_to` are used by `www/.lua/ms-sso.lua`. The `.preload` example program uses `notify_to` when SMTP is configured.

Create `fs-sso/mako.conf`:

```lua
openid={
   tenant="Directory (tenant) ID",
   client_id="Application (client) ID",
   client_secret="client secret Value",
   client_secret_expires="2028-08-19",
   redirect_uri="http://localhost/",

   -- Optional. If omitted, Mako's configured SMTP recipient is used.
   notify_to="server-operators@example.com"
}
```

`client_secret_expires` is optional to the protocol because Entra does not
encode the expiration date in the secret Value. When set, it must be a valid
date; `YYYY-MM-DD` is recommended. When omitted, the module sets it to the
current UTC date so the operator receives an immediate expired-credential
notification. The module checks it at startup and daily and reports the first
configured threshold reached. The defaults are 60, 30, 14, 7, and 1 day.
Override them with `alert_days={90,30,7,1}` in the `openid` table.

If the standard Mako `log.smtp` configuration is present, `.preload` emails
credential events through `require"log".sendmail`. Without SMTP it still writes
the events to trace output.

Run:

```text
cd fs-sso
mako -l::www
```

For more about loading applications with Mako, see the [command-line video
tutorial](https://youtu.be/vwQ52ZC5RRg) and the [Mako application-loading
options](https://realtimelogic.com/ba/doc/en/Mako.html#loadapp).

Open the configured redirect URI, sign in, and then open `/fs/`. Test the
WebDAV session URL in a separate browser or WebDAV client.

## Browser-based secret rotation

The web recovery path is intentional: a VPS operator may have no shell access,
and an embedded RTOS may have no command line or writable configuration file.

1. A normal, state-bound Entra sign-in reaches the token endpoint.
2. Only if Entra returns error `7000215` (invalid secret) or `7000222`
   (expired secret), the same BAS session receives a short-lived recovery form.
3. The operator enters the new client secret **Value** and its expiration date.
4. The module starts a second authorization-code flow and uses the candidate
   secret at the token endpoint.
5. Only a complete, validated OpenID Connect login activates the candidate.

The demo shows an activity indicator and suppresses repeated activation while
each navigation or form submission is pending. Its Content Security Policy
allows form navigation to `https://login.microsoftonline.com`; this is required
because the local recovery POST redirects the browser to Entra.

The recovery form is therefore not a general public configuration endpoint. It
requires a one-time recovery token created after a valid `state` callback, and
the candidate is not tested with an unrelated Microsoft Graph request.

## Reusable module API

Load the app-private module from `.preload`:

```lua
local msSso=appreq"ms-sso"
local sso=msSso.init(openid,{
   notify=function(event)
      -- event contains kind/message/expiry information, never the secret
   end,
   savecredential=function(secret,metadata)
      -- Persist by using the target application's storage model.
      -- Return true on success.
      return true
   end,
   log=function(message) trace(message) end,
   alert_days={60,30,14,7,1}
})
```

`notify(event)` receives one of:

- `credential-expiring`
- `credential-expired`
- `credential-invalid`
- `credential-updated`
- `credential-update-failed`

It never receives the client secret. `savecredential(secret, metadata)` is the
separate, optional callback that receives an Entra-accepted replacement and
`metadata.expires`. If persistence fails, the working value remains active in
memory and `credential-update-failed` is emitted. A failed save does not also
emit `credential-updated`.

For asynchronous storage, the callback can accept a third argument,
`done`, a function, and return the string `"pending"`. Call
`done(ok, errorMessage)` once after the write commits or fails: `ok` is a
boolean and `errorMessage` is an optional string. The module reports the
persistence result when `done` runs. Login still succeeds with the verified
identity and the working secret remains active in memory. The callback must
retain only the supplied values and completion function, never an HTTP
request or its normal response. Existing synchronous callbacks continue to
return `true` for success or `nil, errorMessage` for failure.

The returned object provides:

- `sso.sendredirect(request)` - starts a login using random, session-bound
  `state`, nonce, and an S256 PKCE verifier. Returns boolean `true` after
  redirecting. Before provider initialization completes, returns
  `nil, message, nil, "starting"`, where `message` is a string. The demo
  displays this as a temporary status with a retry link.
- `sso.login(request)` - consumes the callback once, exchanges the code, and
  validates the RS256 ID token signature, issuer, tenant, audience, nonce, and
  time range.
- `sso.rotate(request, secret, expires, recoveryToken)` - stages a candidate
  from the protected recovery flow and verifies it with a real login. It can
  return the same `"starting"` status as `sendredirect`.
- `sso.decode(token)` - verifies the signature of an ID token.
- `sso.close()` - cancels the refresh/notification timer deterministically
  during app unload. The timer is not self-referenced, so garbage collection
  also cancels it if the SSO instance becomes unreachable without `close()`.

The example logs users internally as the immutable `tid:oid` pair. Names and
`preferred_username` are display text only. It stores only that internal ID and
display name in the BAS session; it does not retain an access token.

## Security boundary of this example

This is an authentication and technology example, not a preconfigured file
authorization policy. WFS is intentionally rooted at Mako's disk IO and all
successfully authenticated users receive the same WFS access. A product must
select a dedicated file root and add an authorizer or app-role mapping that
matches its own read/write policy. Those choices cannot be made generically in
`ms-sso.lua`.

The [session URL security](#session-url-security) rules apply to every URL
generated by the demo page or Web File Manager. The demo page generates its URL
only after an explicit click and returns it with `no-store` and `no-referrer`
headers.

Local logout ends the BAS session; it does not end the user's Microsoft browser
session. If the session ends while Web File Manager remains open in another
tab, its next server operation presents a sign-in prompt instead of treating
the login page as a file-service response.

## Flow

```text
Browser -> Mako: GET login page
Mako -> Browser -> Entra: authorize request (state + nonce + PKCE challenge)
Entra -> Browser -> Mako: authorization code + state
Mako -> Entra: code + PKCE verifier + client secret
Entra -> Mako: ID token
Mako: validate token, call request:login(tid .. ":" .. oid)
Mako -> Browser: redirect to the clean application URL
```

## Files

- `www/.preload` - example configuration, notification callback, WFS ownership,
  and unload cleanup.
- `www/.lua/ms-sso.lua` - reusable Entra/OpenID Connect module.
- `www/index.lsp` - browser login, callback, and credential-recovery UI.
- `www/logout.lsp` and `www/help.lsp` - WFS integration pages.
- `www/assets/style.css` - local, dependency-free RTL dark theme.

For Xedge packaging, place the contents of `www` at the ZIP root. Replace the
Mako-specific mail and storage callback in `.preload` with the target product's
own APIs; the SSO module itself can remain unchanged.
