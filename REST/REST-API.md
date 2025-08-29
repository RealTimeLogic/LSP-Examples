# Module rest - Minimal REST-style router for BAS

A tiny, fast router designed for BAS's [Virtual File System](https://realtimelogic.com/ba/doc/en/VirtualFileSystem.html) (VFS). It prioritizes **constant-time exact matches** and **prefix-style greedy wildcards**, using `string.find` in **plain** mode (no patterns/regex), and keeps semantics explicit and predictable.

---

## Quick start

```lua
local app = require"rest".create()

-- Register routes
app:route("GET", "/sensors/temperature", function(env, path, method)
  env.response:write("22.3")
end)

app:route({"GET","POST"}, "/relays/*", function(env, path, method)
  -- `path` is the full relative path (no leading slash), e.g. "relays/1/toggle"
  -- This wildcard route matches anything that starts with "relays/"
  env.response:setstatus(204)
end)

-- Catch root (empty relative path)
app:route("GET", "/*", function(env, path, method)
  env.response:write("root")
end)

-- Mount in VFS at /api (root if no parent dir is provided)
app:install("api")               -- as a new root directory
-- or: app:install("api", parent) -- as a child of an existing VFS directory
```

---

## API Reference

### `local app = require"rest".create()`

Creates/returns a router instance.

---

### `app:route(method, pattern, callback)`

Register a route.

**Parameters**

- `method` - `string` or `{string,...}`  
  One HTTP method (e.g., `"GET"`) or a list (e.g., `{"GET","POST"}`).

- `pattern` - `string` (exact or greedy wildcard)
  - **Exact:** e.g., `/sensors/temperature`  
    Matches **only** the exact same path (trailing slash differences do **not** match).
  - **Greedy wildcard:** e.g., `/relays/*`, `/*`, or `*`  
    Matches any path that **starts with the segment before `*`**.

- `callback` - `function(env, path, method) -> boolean|nil`
  - `env` is the BAS command environment (`_ENV`).
  - `path` is the **relative** path (no leading slash).
  - `method` is the **uppercase** HTTP method.
  - **Return value:**
    - `true` or `nil` → handled; routing stops.
    - `false` → not handled; router continues searching.

**Semantics & matching rules**

- Exact vs wildcard buckets (fast lookup first, then iteration).
- First-registered wildcard wins if multiple match.
- Trailing slashes matter for exact routes.
- `*` and `/*` match the root (empty path).

---

### `app:install(name, [dir])`

Mount the router in the BAS Virtual File System.

**Parameters**

- `name` - `string` Directory name.
- `dir` - `Directory` (optional) Parent node; if `nil`, mounted at root.

**Behavior**

- The router checks exact first, then wildcard in order.
- Callbacks decide whether to handle or pass (`false`).

---

## Error handling patterns

```lua

-- Local 404
app:route({"GET","POST"}, "*", function(env, path)
  env.response:setstatus(404)
  env.response:write("Not Found")
  return true
end)
```

---

## Minimal example

```lua
local app = require"rest".create()

app:route("GET", "status", function(env)
  env.response:write("ok")
  return true
end)

app:route({"GET","POST"}, "relays/*", function(env, path, method)
  return handleRelay(env, path, method)
end)

app:route("GET", "*", function(env)
  env.response:setstatus(404)
  env.response:write("Not Found")
  return true
end)

app:install("api")
```
