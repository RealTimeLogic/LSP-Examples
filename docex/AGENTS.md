# AGENTS.md - Documentation Examples

## Purpose

This directory is an index for runnable examples referenced from the Real Time Logic documentation. It is not a single runnable application. The current child example is `cart/`, which demonstrates BAS virtual file system directory logic for a shopping-cart style route.

## Read First

1. `README.md` - top-level index.
2. `cart/README.md` - runnable child example instructions.
3. `cart/www/.preload` and `cart/www/.cart.lsp` when working on the cart example.

Do not invent BAS virtual file system, directory, response forwarding, or LSP APIs.

## Official Documentation (Source Of Truth)

This `AGENTS.md` may be copied standalone into other work directories. Treat the
local paths below as relative to the directory containing this file.

Before using any public BAS, Mako, Xedge, Xedge32, OPC UA, or AI-skill URL:

1. Look for a local cached copy under `./.agents/reference/rtl/`.
2. If the file is missing and network access is available, download it from the
   listed source URL and save it there before using it.
3. Record the source URL and download date in `./.agents/reference/rtl/manifest.md`
   or in a short header at the top of the cached file.
4. Use the local cached copy for normal work.
5. Re-fetch the public URL only when the user asks for current/latest guidance,
   the cached file is missing, or the cached file conflicts with observed runtime
   behavior.

For fully offline use, copy this `AGENTS.md` together with the
`./.agents/reference/rtl/` directory. If only `AGENTS.md` is copied into an
offline directory, the cache cannot be populated until network access is
available.

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

## Child Examples

- `cart/` - shopping-cart route example using a synthetic BAS directory named `cart` and forwarding requests to `.cart.lsp`.

## Key Files

- `cart/www/.preload` - creates `ba.create.dir("cart")`, installs a directory function, extracts `category` and `color` from the path, and forwards to `/.cart.lsp`.
- `cart/www/.cart.lsp` - renders extracted route values or suggests `/cart/flowers/blue`.
- `cart/www/index.lsp` - redirects to `cart/`.

## Change Guidance

- Keep this directory as an index unless adding a new documentation child example.
- Put runnable examples in child directories with their own README, AGENTS, and catalog when they become substantial.
- For `cart/`, preserve the VFS directory-function pattern; that is the point of the documentation example.

## Run And Verify

There is no top-level run command. For the cart child example:

```bash
cd docex/cart
mako -l::www
```

Verify `/cart/flowers/blue` renders category and color values.
