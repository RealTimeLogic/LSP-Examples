# AGENTS.md - Documentation Examples

## Purpose

This directory is an index for runnable examples referenced from the Real Time Logic documentation. It is not a single runnable application. The current child example is `cart/`, which demonstrates BAS virtual file system directory logic for a shopping-cart style route.

## Read First

1. `README.md` - top-level index.
2. `cart/README.md` - runnable child example instructions.
3. `cart/www/.preload` and `cart/www/.cart.lsp` when working on the cart example.

Do not invent BAS virtual file system, directory, response forwarding, or LSP APIs.

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
