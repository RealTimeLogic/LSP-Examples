# SharkTrust ACME Examples

These examples show how a Barracuda App Server (BAS) application can obtain
and renew Transport Layer Security (TLS) certificates through the Automatic
Certificate Management Environment (ACME) protocol. Choose the example that
matches how the device proves control of its domain and installs certificates.

DNS validation is usually the best starting point for memory-constrained
embedded systems because the certificate service does not need to connect
directly to the device.

| Example | Use it when |
| --- | --- |
| [HTTP-01](http/README.md) | Mako Server or Xedge can receive the ACME service's HTTP validation request and should install the certificate automatically. |
| [Automatic DNS-01](dns/README.md) | Mako Server or Xedge should use SharkTrust to manage DNS validation and install the certificate automatically. The example supports an embedded zone identity or explicitly configured portal credentials. |
| [Standalone BAS DNS-01](dns-standalone/README.md) | A custom BAS host uses SharkTrust DNS validation and needs its own certificate installer. The example creates an HTTPS listener on port 9443. |
| [Manual DNS-01](manual/README.md) | An operator must publish the DNS TXT record manually and continue the certificate request through a browser interface. |

Each README explains the required settings and how to run that example. Start
with the ACME staging service, then switch to production after the complete
workflow succeeds.

These examples use the compact ACME API: `acme/runtime` owns certificate
management, and `acme/dns` supplies automatic and manual DNS adapters.
Notifications pass one integer code. Use the matching updated `mako.zip`.
The individual READMEs explain private configuration and writable state.

See [verification results and repeatable local tests](TESTING.md) for the
checks performed with the compact package and the remaining operator tests.

## Supply an Explicit Portal Identity

The two automatic DNS examples accept a host-owned `proof(message)` callback.
The core does not accept or save a zone secret. If you omit the explicit
identity fields, it uses the compiled `etokengen` or `tokengen` identity.

For explicit credentials on Mako, put this configuration in a private
`mako.conf`, outside `www` and Git. Replace the placeholders and select a
private writable `homeio` for each example. Do not also configure Mako's
top-level `acme` table: the example owns this runtime.

```lua
-- Capture globals now: Mako detaches the configuration environment after loading.
local ba,string,tonumber=ba,string,tonumber
local zoneKey="<64-hexadecimal-character-zone-key>"
local zoneSecret="<64-hexadecimal-character-zone-secret>"

sharkTrustExample={
   acceptTerms=true, -- Enable only after accepting the provider's terms.
   email="operator@example.com",
   domains={"controller-17"},
   production=false,
   namePolicy="exact",
   keyType="ecc", -- Or "rsa" with bits=2048.
   challenge={
      type="dns-01",
      portalUrl="https://portal.example.com",
      zoneKey=zoneKey,
      dns="local",
      proof=function(message)
         -- Recalculate the derived key for each proof; retain only host credentials.
         local salt=zoneKey:gsub("%x%x",function(pair)
            return string.char(tonumber(pair,16))
         end)
         local key=ba.crypto.PBKDF2("sha256",zoneSecret:upper(),salt,1000,32)
         return ba.crypto.hash("hmac","sha256",key)(message)(true,"binary")
      end
   }
}
```

`zoneKey` and `zoneSecret` are required strings of exactly 64 hexadecimal
characters supplied by the host; neither has a default. `portalUrl` is the
required HTTPS portal URL string. `proof` is a required synchronous function
for an explicit identity, with no default. It receives the exact binary-safe
message string, including any NUL bytes, and returns a 32-byte binary string.
It must not yield or change the message. The client base64url-encodes the result.

The callback uses PBKDF2-HMAC-SHA-256 with the secret's 64 uppercase ASCII
characters as its password, the hex-decoded 32-byte zone key as its salt,
1000 iterations, and 32 output bytes. Do not hex-decode the secret. It then
calculates HMAC-SHA-256 over the unchanged message. The host owns the original
credentials and supplies this callback on every startup.

An application can instead assign a matching compiled module's `proof`
function directly. Its portal and zone key must match the configured values.
Keep secrets and proofs out of logs. The HTTP-01 and manual DNS examples do
not use a SharkTrust proof callback.
