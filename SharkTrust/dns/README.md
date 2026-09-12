# Automatic DNS-01 ACME Example

This example obtains and renews a TLS certificate through a SharkTrust-managed
DNS-01 challenge. It runs as a Mako Server or Xedge application and lets the
host install the certificate in its existing HTTPS listeners.

## Configure the Identity

For Mako, copy the `config` table from [`www/.preload`](www/.preload)
into a private `mako.conf`, change `local config=...` to
`sharkTrustExample = {`, and configure its values. Keep this file outside
`www` and out of Git. Embedded hosts can configure the table in `.preload`.
You must set the email address, the first name in `domains`,
and terms acceptance.

Leave `challenge.portalUrl`, `challenge.zoneKey`, and `challenge.proof` set
to `nil` to use the host's compiled `etokengen` or `tokengen` identity.
For an explicit identity, supply the HTTPS portal URL, the 64-character
hexadecimal zone key, and a synchronous `proof(message)` callback returning
32 binary bytes. The runtime no longer accepts `challenge.secret`.

See the [host proof callback example](../README.md#supply-an-explicit-portal-identity)
for the complete private configuration and required calculation. A partial
explicit identity is rejected.

Keep `production=false` until the complete staging flow works. The
writable state contains a secret device credential and must not be included in
an application package, source repository, log, or diagnostic download.

## Run

Run the example with Mako Server from this directory:

```console
mako -l::www
```

For Xedge, create or import an application whose root contains the contents of
`www`, then start the application.

The runtime selects one writable I/O automatically: `home` on Mako and `disk`
on Xedge. ACME state is stored below `acme`, and the assigned device name and
credential are stored in `acme/sharktrust.json`.

At startup, the client discovers the local IPv4 address used to reach the
portal and sends it automatically. If DHCP or another network event later
reports a new address, call:

```lua
runtime:setIpAddress(newIpAddress, function(ok, problem)
   -- Handle a failed portal or DNS update here.
end)
```

`newIpAddress` must be a dotted-decimal IPv4 string such as `192.168.1.20`.

## Current ACME API

Use a `mako.zip` containing `acme/runtime` and the compact `acme/dns` API.
The example's `notify(code)` callback receives one integer; it logs the code
without indexing an event table. See the [ACME notification codes](https://realtimelogic.com/ba/doc/en/lua/acme.html#notifications)
for their meanings. Code 2 means startup completed; code 40 means a certificate
was issued and saved. Startup can reuse an existing certificate without code 40.

Use a separate writable home for each example so their account, certificate,
and registration state remain independent. Keep an HTTPS listener enabled for
certificate installation. Stop Mako with Ctrl+C; `onunload()` closes the runtime.

This is a certificate-management example with no application page. A browser
request to `/` can return HTTP 404 even after TLS installation succeeds.

The configuration table has the same fields as Mako's top-level `acme` table.
`Runtime.create()` resolves the embedded identity and creates the DNS adapter;
application code does not need its own identity lookup or registration wrapper.
