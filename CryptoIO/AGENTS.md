# AGENTS.md - CryptoIO

## Purpose

This example provides `CryptoIO.lua`, a reusable Lua module that wraps a BAS IO object with AES-GCM encrypted file storage. The startup script demonstrates a round-trip encryption test and mounts an encrypted Web File Server/WebDAV endpoint.

Use this example for encrypted-at-rest file storage, Lua IO wrappers, WebDAV over encrypted storage, and TPM-derived key usage.

## Read First

1. `README.md` - module API, file format, key security notes, and run instructions.
2. `www/.lua/CryptoIO.lua` - reusable encrypted IO implementation.
3. `www/.preload` - smoke test and encrypted Web File Manager setup.

Do not invent BAS IO, Crypto, TPM, WebDAV, Web File Server, or authenticator APIs.

## Official Documentation (Source Of Truth)

- **BAS documentation bundle (`basapi.md`)**  
  https://realtimelogic.com/downloads/basapi.md

- **BAS tutorials bundle (`tutorials.md`)**  
  https://realtimelogic.com/downloads/tutorials.md

- **Mako Server tutorials bundle (`tutorials.md`)**  
  https://makoserver.net/download/tutorials.md

Reference priority:

1. `basapi.md` for API syntax, signatures, and behavior.
2. `tutorials.md` for architecture, security, deployment, and tutorial context.
3. If tutorial guidance conflicts with API details, trust the API reference.

## Key Files

- `www/.lua/CryptoIO.lua` - factory module returning an encrypted IO from an existing IO, key name, and options.
- `www/.preload` - loads the module, encrypts/decrypts `README.md`, creates `README.encrypted`, mounts `/fs/`, and protects it with `admin` / `admin`.

## Change Guidance

- Do not change the encrypted file format casually; existing encrypted files depend on block size, IV, GCM tags, ciphertext layout, and trailer format.
- Treat `keyname` as security-sensitive design input even though the actual key is TPM-derived.
- Keep `op.size` validation strict: it must be at least 16, divisible by 16, and not exceed `0xFFF0`.
- When changing WebDAV setup, preserve lock directory handling and `onunload()` cleanup.
- If adapting to Xedge, review writable storage location, key policy, and whether the target allows user-installed Lua code.

## Run And Verify

```bash
cd CryptoIO
mako -l::www
```

Verify the console prints `.preload encrypt/decrypt test: OK`, then open `/fs/` and log in with `admin` / `admin` to test encrypted file storage.
