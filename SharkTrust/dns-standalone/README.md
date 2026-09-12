# Standalone BAS DNS-01 ACME Example

This example obtains and renews a TLS certificate through a SharkTrust-managed
DNS-01 challenge without relying on the Mako Server or Xedge certificate
installer. Its installation callback creates an HTTPS listener on port 9443.

## Host Requirements

The BAS host must provide the ACME Lua modules, a writable I/O interface named
`disk`, the standard BAS JSON and TLS APIs, and an active Socket Event
Dispatcher. Change the `ba.openio(...)` selection if the host registers its writable
I/O under another name. When testing under Mako, the example uses `home`.
Port 9443 must be available when the first certificate is installed.

## Configure and Run

For Mako, copy the `config` table from [`www/.preload`](www/.preload)
into a private `mako.conf`, change `local config=...` to
`sharkTrustExample = {`, and configure its values. Keep this file outside
`www` and out of Git. Embedded hosts can configure the table in `.preload`.
You must set the email address, the first name in `domains`,
and terms acceptance. At startup, the client discovers the local IPv4 address
used to reach the SharkTrust portal and sends it automatically.

Leave `challenge.portalUrl`, `challenge.zoneKey`, and `challenge.proof` set
to `nil` to use the host's compiled `etokengen` or `tokengen` identity.
For an explicit identity, supply the HTTPS portal URL, the 64-character
hexadecimal zone key, and a synchronous `proof(message)` callback returning
32 binary bytes. The runtime no longer accepts `challenge.secret`.

See the [host proof callback example](../README.md#supply-an-explicit-portal-identity)
for the complete private configuration and required calculation. A partial
explicit identity is rejected.

Keep `production=false` until the complete staging flow works. Load
`www` as an application from the host's C startup code or normal
application-loading mechanism.

After issuance, connect to:

```text
https://device-name:9443/
```

The callback combines a PEM certificate and software private key with
`ba.create.sharkcert()`. For an ECC key held by the host TPM, it restores the
named key when necessary and calls `ba.tpm.sharkcert()` instead. The host TPM
must provide `haskey`, `createkey`, and `sharkcert`. The callback adds the
certificate object to a server-mode SharkSSL object and creates the listener with
`ba.create.servcon(9443, {shark=shark})`. Renewal recycles the existing listener
so active connections can finish normally.

The writable state contains ACME private keys and a secret SharkTrust device
credential. Keep it outside the application image, source repository, logs,
and diagnostic downloads.

If DHCP or another network event later reports a new address, call
`runtime:setIpAddress(newIpAddress, callback)`. `newIpAddress` must be a
dotted-decimal IPv4 string such as `192.168.1.20`. The portal then updates the
device's DNS A record.

## Current ACME API

Use a `mako.zip` containing `acme/runtime` and the compact `acme/dns` API.
The example's `notify(code)` callback receives one integer; it logs the code
without indexing an event table. See the [ACME notification codes](https://realtimelogic.com/ba/doc/en/lua/acme.html#notifications)
for their meanings. Code 2 means startup completed; code 40 means a certificate
was issued and saved. Startup can reuse an existing certificate without code 40.

Use a separate writable home for each example so their account, certificate,
and registration state remain independent. The example opens its own HTTPS
listener on port 9443; it does not require a pre-existing HTTPS listener.
Stop Mako with Ctrl+C; `onunload()` closes the runtime.

For a Mako test, run `mako -c mako.conf -l::www` from this directory.
This exercises the custom installer on Mako; it does not validate a different
native BAS host or its platform integration.

This is a certificate-management example with no application page. A browser
request to `/` can return HTTP 404 even after TLS installation succeeds.

The configuration table has the same fields as Mako's top-level `acme` table.
`Runtime.create()` resolves the embedded identity and creates the DNS adapter;
application code does not need its own identity lookup or registration wrapper.
