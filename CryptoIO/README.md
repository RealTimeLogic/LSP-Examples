# CryptoIO

## Overview

A Lua module that wraps a [Barracuda IO](https://realtimelogic.com/ba/doc/en/lua/lua.html#ba_ioinfo) with transparent **AES-GCM file encryption** so applications can keep normal file I/O APIs while storing data encrypted at rest.

Module CryptoIO ([www/.lua/CryptoIO.lua](www/.lua/CryptoIO.lua)) is a Lua module that wraps an existing IO instance and exposes a new encrypted IO via [ba.create.luaio](https://realtimelogic.com/ba/doc/en/lua/auxlua.html#luaio). It encrypts file content with `ba.crypto.symmetric("GCM", ...)` and keeps directory operations delegated to the wrapped `io`.

## Files

- `www/.lua/CryptoIO.lua` - The reusable encrypted IO module.
- `www/.preload` - Startup script that demonstrates both the smoke test and the encrypted WebDAV/file-server setup.

## How to run

The [www/.preload](www/.preload) script includes two examples showing how to use CryptoIO. Run the examples with the Mako Server:

```bash
cd CryptoIO
mako -l::www
```

## How it works

### Example 1: Basic Encrypt/Decrypt Smoke Test

The first section in `.preload` verifies that `CryptoIO.lua` can round-trip file data correctly.

**High-level flow:**

1. Create a base I/O (`hio`) for the home directory.
2. Wrap it with `CryptoIO` to get an encrypted I/O (`cio`).
3. Read plaintext from `README.md` using `hio`.
4. Write that plaintext to `README.encrypted` using `cio` (this writes encrypted bytes on disk).
5. Compare file sizes:
   - `hio:stat("README.encrypted").size` = encrypted size on disk
   - `cio:stat("README.encrypted").size` = original plaintext size decoded from CryptoIO trailer
6. Open `README.encrypted` through `cio`, read decrypted content, and compare with original plaintext.

If the comparison matches, encryption + decryption are working as expected.

### Example 2: Encrypted Web File Manager + WebDAV

The second section in `.preload` sets up an encrypted file service mounted at `/fs/`. The example is similar to the [WebDAV and Web File Server example](../File-Server/README.md), but it uses CryptoIO to encrypt all files stored on the file system. It creates an `encrypted` sub-directory and uses it as the base for all encrypted resources.

After starting the Mako Server, open a browser and go to `http://localhost:portno/fs/`, where `portno` is the HTTP port printed by the server.

**Login credentials:**

- Username: `admin`
- Password: `admin`

**High-level flow:**

1. Ensure an `encrypted` directory exists in the base storage.
2. Create a sub-IO for that directory and wrap it with `CryptoIO` (`wdio`).
3. Create a lock directory (`/.LOCK`) for WebDAV locks.
4. Create and mount a Web File Server (`ba.create.wfs`) using `wdio`.
5. Add simple auth (`admin`/`admin`) and attach it to the mounted directory.
6. Register `onunload()` to unmount the file server cleanly.
7. Print a directory listing by iterating `wdio:files("/", true)`.


### API

The module does not return a Lua table, but a factory function:

```lua
local CryptoIO = require "CryptoIO"
local eio = CryptoIO(io, keyname, op) -- Create encrypted IO
```

Factory arguments:

- `io` (userdata): existing BAS io instance to wrap
- `keyname` (string): [TPM key name](https://realtimelogic.com/ba/doc/en/lua/auxlua.html#ba_tpm_globalkey) used to derive the symmetric key. Key derivation:
  - `ba.tpm.uniquekey(keyname, 32)` is hashed with SHA-256 and used as GCM key material.
  - [See keyname security note](#keyname-security-note)
- `op` (table, optional)
- `op.size` (default `1024`): encryption block size (`>= 16`, divisible by `16`, and `<= 0xFFF0`). **Note:** the block size must be the same for encryption and decryption; it cannot be changed after a file has been written.
- `op.auth` (optional): Additional Authenticated Data (AAD) for GCM passed to [s:setauth(op.auth)](https://realtimelogic.com/ba/doc/en/lua/auxlua.html#ba_crypto_symmetric)


Returned encrypted `io` supports:

- `open(name, mode)` where mode must be `"r"` or `"w"`
- `files(name)`
- `stat(name)` (returns decrypted size for encrypted files)
- `mkdir(name)`, `rmdir(name)`, `remove(name)` (delegated)

Opened file handle methods:

- `read(size)`: reads decrypted bytes; default size is `512`; returns `nil` on EOF. On decryption error: returns nil, "enoent".
- `write(data)`: encrypts and writes data
- `flush()`: forwards to underlying `fp:flush()` in write mode; read mode flush is not allowed
- `close()`: write mode writes trailer and closes; read mode closes
- `seek()`: not implemented (raises error)

### Basic Example

```lua
local CryptoIO = require "CryptoIO"

-- baseIo is your existing BAS io instance
local encryptedIo = CryptoIO(baseIo, "my-device-key", {
   size = 1024,
   auth = "my-aad-v1"
})

-- Write encrypted file
do
   local fp, err = encryptedIo:open("data.bin", "w")
   assert(fp, err)
   assert(fp:write("hello "))
   assert(fp:write("world"))
   assert(fp:flush())
   assert(fp:close())
end

-- Read decrypted file
do
   local fp, err = encryptedIo:open("data.bin", "r")
   assert(fp, err)
   local data = {} -- Begin
   while true do
      local chunk, rerr = fp:read(256)
      if not chunk then
         assert(not rerr, rerr) -- nil means EOF
         break
      end
      data[#data + 1] = chunk
   end
   local plaintext = table.concat(data) -- End
   -- Alternative to above Begin - End: local plaintext,err="fp:read"a"
   assert(fp:close())
   -- plaintext == "hello world"
end
```

### Encrypted File Format

File layout:

```text
+-------------------+-------------------------------+-----------------------+
| IV (12 bytes)     | (TAG + CIPHERTEXT) repeated   | END-DATA (8 bytes)    |
+-------------------+-------------------------------+-----------------------+
```

Details:

1. `IV`:
First 12 bytes in file and used to initialize GCM for the file stream.

2. Repeated encrypted payload blocks:
Each block is written as `TAG` (16 bytes) followed by `CIPHERTEXT` (up to `op.size` bytes for full blocks; last block may be shorter). Multiple `(TAG + CIPHERTEXT)` pairs may exist.

3. `END-DATA` trailer (8 bytes total):
`u32(size)` + `u32(-size)` (both big-endian 4-byte values). `size` is the original plaintext file size. `-size` is encoded as 32-bit two's complement and used as a consistency check.

`stat` behavior for encrypted files:

- Reads trailer and validates the two size values.
- On success returns table `st` with `st.size = plaintext_size`
- On failure (not encrypted/corrupt trailer): returns `nil, "enoent"`.

## Notes / Troubleshooting

### Keyname Security Note

`CryptoIO` derives its AES key from [ba.tpm.uniquekey(keyname, 32)](https://realtimelogic.com/ba/doc/en/lua/auxlua.html#ba_tpm_globalkey). This means the `keyname` alone is not sufficient to decrypt files on another device, because the derived key is also bound to the local softTPM state.

In deployments where the Barracuda App Server is configured to run only manufacturer-signed ZIP applications, storing `keyname` as plaintext is normally acceptable in practice. Since untrusted Lua code cannot be installed or executed, an attacker cannot simply supply the same `keyname` to `ba.tpm.uniquekey()` and recover the encryption key.

If the product allows end users or third parties to add their own Lua code, then protecting `keyname` becomes more important, because code running on the same device may be able to request the same TPM-derived key. In that type of deployment, you should combine signed application control with any additional protections appropriate for your design.

Keeping `keyname` inside an AES-encrypted ZIP file is therefore optional defense in depth, not a strict requirement for normal CryptoIO deployments based on signed ZIP applications. For more information, see the tutorial [Signed and Encrypted ZIP files](https://realtimelogic.com/ba/doc/en/C/reference/html/SignEncZip.html).
