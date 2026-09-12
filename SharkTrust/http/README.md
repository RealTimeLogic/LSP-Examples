# HTTP-01 ACME Example

This example obtains and renews a TLS certificate through an HTTP-01 challenge.
It runs as a Mako Server or Xedge application and lets the host install the
certificate in its existing HTTPS listeners.

## Configure and Run

For Mako, copy the `config` table from [`www/.preload`](www/.preload)
into a private `mako.conf`, change `local config=...` to
`sharkTrustExample = {`, and configure its values. Keep this file outside
`www` and out of Git. Embedded hosts can configure the table in `.preload`. Keep `production=false` until the complete staging flow works. Set
`acceptTerms=true` only after accepting the selected ACME provider's terms.

Run the example with Mako Server from this directory:

```console
mako -l::www
```

For Xedge, create or import an application whose root contains the contents of
`www`, then start the application.

The configured domains must resolve to the server, and the ACME service must be
able to reach the server on public TCP port 80 over HTTP. Mako or Xedge must already have its normal
HTTPS listener because the ACME runtime replaces that listener's certificate
without restarting the server.

The runtime selects the normal writable I/O automatically: `home` on Mako and
`disk` on Xedge. It stores ACME account and certificate state below its default
`acme` directory.

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
