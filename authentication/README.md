# Lua Authentication Examples

## Overview

These examples provide a practical introduction to the Barracuda App Server authentication mechanism. The examples are designed to be loaded as root applications in the Mako Server, and they demonstrate three different protection patterns:

- protecting the entire application root
- protecting a specific subdirectory
- applying authentication manually on a per-page basis

One of the strengths of BAS authenticators is that they can be decoupled from the resources they protect. That reduces the chance of accidentally leaving an individual page unprotected.

The examples are typically loaded as root applications in Mako Server, which is why the generic startup pattern is simply `mako -l::dir-name`.

## Files

- `root/.preload` - Protects the entire application directory with a BAS authenticator.
- `root/.login/` and `root/public/` - Login UI and public assets for the root example.
- `subdir/.preload` - Builds a virtual directory branch so only a subdirectory is protected.
- `subdir/my-protected/index.lsp` - Protected page for the subdirectory example.
- `semiautomatic/.preload` - Shows how to call the authenticator manually inside shared page logic.
- `semiautomatic/page1.lsp`, `page2.lsp`, `page3.lsp` - Example pages using the shared header/footer authentication pattern.

## How to run

Run the examples from the `authentication/` directory with the Mako Server:

```bash
mako -l::root
mako -l::root digest|form

mako -l::subdir
mako -l::subdir digest|form

mako -l::semiautomatic
```

Login credentials for all examples:

- Username: `admin`
- Password: `admin`

If you switch between Digest or Basic authentication and another authentication mechanism, restart the browser so cached credentials do not interfere with testing.

Prerequisite reading:

- [Authenticator Concept](http://realtimelogic.com/ba/doc/?url=doc/en/authentication.html)
- [Introduction to Lua Authentication](https://realtimelogic.com/ba/doc/?url=en/lua/lua.html#auth_overview)

## How it works

### `root`

The `root` example applies an authenticator directly to the application's resource reader, so the whole app is protected. Resources under `/public/` remain accessible before login, which lets the login page load its CSS, icons, and images.

### `subdir`

The `subdir` example protects only part of the application. Instead of attaching an authenticator to the entire resource reader, it creates a virtual directory with the same name as the protected branch and inserts it as a prologue directory. That way, requests under `my-protected/` trigger authentication before the underlying files are served.

### `semiautomatic`

The `semiautomatic` example shows how to call the authenticator explicitly from shared page logic. The common header authenticates the request, renders the menu, and ensures that forgetting the shared wrapper is visually obvious. This pattern gives finer control, but it also requires more discipline than directory-based protection.

One reason this example exists is that per-page authentication is easy to get wrong. When protection is handled centrally at the directory level, any new page added beneath that directory is automatically protected. When protection is handled manually, forgetting one page can create a security hole. The shared header/footer approach helps reduce that risk by making the common authentication step part of the page structure.

## Notes / Troubleshooting

- Form-based authentication is more flexible because it lets you build a custom login page, but plain HTTP form login is not secure unless you use the encrypted-password approach described here: https://realtimelogic.com/ba/doc/en/lua/lua.html#EncryptedPasswords
- The [Dynamic Navigation Menu](../Dynamic-Nav-Menu/README.md) example shows a stronger form-based approach that works even on plain HTTP by storing hashed credentials.
- In the `root` example, `/public/` remains accessible before login so the login page can load the resources it needs.
- In the `subdir` example, the goal is to protect only a subset of the resource reader rather than the entire application tree.
- Additional example: [Single Sign On using OpenID Connect](../fs-sso/README.md)
- If you switch between Basic, Digest, and form-based testing, restart the browser so old credentials do not mask the behavior you are trying to observe.
