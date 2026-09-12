# Verification with the Proof Callback API

Verified September 6, 2026 using Mako Server 4.3 / BAS library 5921 and the
updated shared ACME runtime. The two automatic DNS examples now use
`challenge.proof` instead of the removed `challenge.secret`. HTTP-01 and
manual DNS needed no code changes. No native rebuild or portal deployment
was done, and this example check requested no new certificates.

The final resource archive is installed beside the debug `mako.exe` in:

```text
C:\Users\wini\develop\WebServer\BAS\examples\MakoServer\obj\debug
```

Its SHA-256 is `2acd9a7ce058e93748e1161a4a0af317daa2b7bd06c49fbe4ee559d95b14d893`.
The updated local `BAS/doc/en/lua/acme.html` documents this API.

## Executed example checks

| Example | Callback-API package result |
| --- | --- |
| `dns/www` | Portal registration confirmed through the host proof callback; existing RSA-2048 staging certificate installed and served. |
| `dns-standalone/www` | Portal registration confirmed through the callback; ECC P-384 native TPM certificate installed through the custom listener on port 9443. |
| `http/www` | Existing staging certificate restored and served. Public CA HTTP-01 issuance was not run. |
| `manual/www` | Existing staging certificate restored and served; page returned HTTP 200 and read-only status reported ready. Manual TXT publication, Continue, Cancel, and issuance remain for the user. |

All four served the same leaf fingerprints as before the API migration.
TLS 1.3 verification checked the saved leaf bytes, hostname, expiry, and key
algorithm while explicitly trusting the exact staging leaf. These are not
publicly trusted production certificates. Certificate-only examples returned
404 at `/`; the manual app returned 200. No Lua exception was observed.

In the September 5 tests, the automatic DNS examples completed real RSA and ECC
staging issuance through `x.sharkssl.com`, including TXT cleanup. During the
common-API change, fresh real issuance additionally passed in Mako, Mako +
Xedge, and standalone Windows Xedge using three new test names. The full report
is `C:\Users\wini\develop\WebServer\BAS-Resources\doc\acme-common-api-results.md`.

The September 6 full-client tests and their separate initial Xedge harness
incident are recorded in
`C:\Users\wini\develop\WebServer\BAS-Resources\development\full-client-proof-results.md`.
This example check does not change that incident's cleanup status.

The shared README's complete configuration was evaluated with synthetic
credentials. After its Mako configuration environment was detached, the
callback matched an independent Python PBKDF2/HMAC calculation. The current
`Dns.createClient()` accepted it. The check ended with
`README_PROOF_CALLBACK_PASS` and made no network request.

The downloaded BAS reference calls PBKDF2's output-length argument a bit
length. The runtime and independent test confirm that passing 32 returns
32 bytes, which is the contract used by these examples.

## Repeat the tests

Private configurations, launchers, certificate state, and verification script:

```text
C:\tmp\sharktrust-proof-examples-20260906\live
```

The two DNS private `mako.conf` copies now use host proof callbacks and
explicitly select `https://x.sharkssl.com`. HTTP and manual settings needed
no API change. All four copies retain `production=false` and use their own
writable homes. The original September 5 homes were not modified. Credentials
and private key state stay outside the application packages and Git.

```powershell
# Start each desired example in its own terminal.
& C:\tmp\sharktrust-proof-examples-20260906\live\dns\run.ps1
& C:\tmp\sharktrust-proof-examples-20260906\live\dns-standalone\run.ps1
& C:\tmp\sharktrust-proof-examples-20260906\live\http\run.ps1
& C:\tmp\sharktrust-proof-examples-20260906\live\manual\run.ps1

# With all four running:
python C:\tmp\sharktrust-proof-examples-20260906\live\verify-live.py --restart
```

Manual UI: `http://127.0.0.1:18183/`. Its private home contains a copied staging
certificate for startup checks. For a full manual issuance test, follow
[the tutorial](manual/README.md) with a fresh domain whose TXT records you can
edit. The repository's manual `mako.conf` template is unchanged.

All test processes were stopped after verification. No public HTTP-01 issuance,
ESP32 hardware, or separate native custom-installer host was tested. The
`dns-standalone` custom installer was exercised on Mako; the separately tested
Windows Xedge executable uses its own standard installer.

This run ended with `CERTIFICATE_RESTART_REUSE_PASS` and `EXAMPLE_TLS_PASS`.
The log is in the new workspace's `live/verification.log`; the documented
callback check is in `callback-check.log`. No Xedge app installation or manual
DNS action was performed in this step.

The six changed example/documentation files were backed up under
`C:\tmp\sharktrust-proof-examples-20260906\before`. Changes are limited to the
two DNS `.preload` files and READMEs, the shared README, and this test record.

The original compact-example snapshot is at
`C:\tmp\SharkTrust-examples-20260905\before`. The snapshot immediately before
the common-API edits is at `C:\tmp\acme-common-20260905-01\examples-before`.
The example tree was already untracked; unrelated repository edits were kept.
