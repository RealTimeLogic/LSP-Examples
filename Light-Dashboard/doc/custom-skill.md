---
name: light-dashboard-custom
description: Use when modifying the Light Dashboard `custom/` variant. Covers the custom mini-CMS engine, layout and color customization, adding/removing pages, HTMX navigation, and CMS-level SMQ page scopes.
---

# Light Dashboard Custom Variant Skill

Use this skill when developing the `custom/` dashboard variant in this repo.
The `custom/` variant is the primary target for new work. It uses:

- a small database-free CMS in `custom/.lua/cms.lua`;
- a shared shell in `custom/.lua/www/template.lsp`;
- HTMX fragment navigation;
- custom CSS in `custom/static/styles.css`;
- a two-level menu from `custom/.lua/menu.json`;
- CMS-level SMQ support from `custom/static/cms-smq.js`;
- native JavaScript only for custom application code.

Do not use this skill for the `www/` or `htmx/` variants unless the user
explicitly asks for parity across variants.

## First Files to Read

Before making changes, inspect the relevant files:

- `custom/.lua/cms.lua` for routing, full-page vs HTMX response behavior, and security headers.
- `custom/.lua/www/template.lsp` for the shell, menu rendering, global assets, and `#main`.
- `custom/.lua/menu.json` for navigation and routing.
- `custom/static/styles.css` for layout, colors, typography, forms, and navigation styles.
- `custom/static/ui.js` for menu toggling and active navigation state.
- `custom/static/cms-smq.js` when adding or modifying SMQ behavior.
- `custom/.preload` and `custom/SMQ/index.lsp` for server-side SMQ broker behavior.
- `doc/custom-design.md` for detailed architecture notes.

## Core Architecture

The CMS is designed to behave like a normal server-rendered site on direct page
loads and like a lightweight SPA when HTMX is available.

Request flow:

1. Static files are served first by the resource reader.
2. Unmatched requests fall through to `cmsfunc(...)` in `custom/.lua/cms.lua`.
3. Directory requests are normalized to `index.html`.
4. HTML pages must be registered in `custom/.lua/menu.json`.
5. Normal requests return the full `template.lsp` shell.
6. HTMX requests return only the page fragment.
7. HTMX history-restore requests return the full shell.

The shell keeps persistent app-level behavior:

- navigation menu;
- `#main` fragment target;
- HTMX;
- `/rtl/smq.js`;
- `custom/static/cms-smq.js`;
- `custom/static/ui.js`.

Page fragments live in `custom/.lua/www/*.html` and are injected into
`#main`.

## Layout and Color Customization

Modify layout and visual design primarily in `custom/static/styles.css`.

Start with `:root` variables:

- `--page-bg`, `--main-bg`;
- `--surface`, `--surface-muted`;
- `--text`, `--muted`;
- `--border`, `--shadow`;
- `--nav-width`, `--nav-bg`, `--nav-surface`;
- `--nav-text`, `--nav-muted`, `--nav-accent`;
- `--link`, `--accent`, `--accent-ink`;
- `--radius`, `--radius-sm`.

Use these variables before hardcoding new colors. Keep the palette balanced:
avoid making the whole UI a single hue family. The existing structure is:

- `#layout` is the full app shell.
- `#menu.side-nav` is the left navigation.
- `#main.main-pane` is the content area and HTMX history element.
- `.header` is the page heading band.
- `.content` is the page body container.
- `.panel`, `.form`, `.form-grid`, `.form-field`, `.form-actions`, `.btn` are reusable form/control primitives.

When changing the shell layout:

- edit `custom/.lua/www/template.lsp` only for structural shell changes;
- keep `id="main"` and `hx-history-elt` on the main content pane;
- keep nav links using `hx-get`, `hx-push-url="true"`, and `hx-target="#main"`;
- keep `/rtl/smq.js`, `/static/cms-smq.js`, and `/static/ui.js` loaded by the shell;
- do not add cache-busting query strings to reusable template assets.

When changing colors:

- update `:root` first;
- check nav active, hover, focus, and nested group states;
- check form controls and buttons;
- check mobile nav behavior around the breakpoint at the bottom of `styles.css`.

When adding page-specific styling:

- create a page-specific CSS file in `custom/static/`;
- link it from the page fragment, not the global shell, unless it is truly global;
- update Content Security Policy in `custom/.lua/cms.lua` only if external assets are added.

## Navigation and Menu Behavior

Navigation source of truth is `custom/.lua/menu.json`.

Top-level item:

```json
{ "name": "Diagnostics", "href": "Diagnostics.html" }
```

Nested group:

```json
{
  "name": "System",
  "children": [
    { "name": "Diagnostics", "href": "Diagnostics.html" }
  ]
}
```

Authenticated-only item:

```json
{ "name": "Sign Out", "href": "logout.html", "auth": true }
```

`template.lsp` renders this menu and marks the active item with `is-active`.
`custom/static/ui.js` keeps the active menu item and `document.title`
synchronized after HTMX navigation and browser history restore.

If you change class names in the menu, update both:

- `custom/.lua/www/template.lsp`;
- `custom/static/ui.js`;
- related nav selectors in `custom/static/styles.css`.

## Add a Page

1. Create a fragment in `custom/.lua/www/`, for example
   `custom/.lua/www/Diagnostics.html`.

Use this basic structure:

```html
<div class="header">
  <h1>Diagnostics</h1>
  <h2>System status and runtime checks</h2>
</div>

<div class="content">
  ...
</div>
```

2. Register it in `custom/.lua/menu.json`.

Top-level:

```json
{ "name": "Diagnostics", "href": "Diagnostics.html" }
```

Nested:

```json
{
  "name": "System",
  "children": [
    { "name": "Diagnostics", "href": "Diagnostics.html" }
  ]
}
```

3. Add page-specific assets if needed.

Place assets in `custom/static/`:

```html
<link href="/static/Diagnostics.css" rel="stylesheet" />
<script src="/static/Diagnostics.js"></script>
```

Put page scripts after the DOM they use, typically at the end of the fragment.
Use native JavaScript only.

4. Verify:

```bash
mako -l::custom
```

Then test:

- direct navigation to `/Diagnostics.html`;
- clicking the menu item through HTMX;
- browser back/forward;
- no-JS fallback if the change is supposed to support no-JS behavior.

## Modify a Page

- Edit the fragment in `custom/.lua/www/`.
- Update page-specific assets in `custom/static/`.
- If the label, location, or auth visibility changes, update `custom/.lua/menu.json`.
- Keep `.header` and `.content` wrappers unless there is a deliberate layout reason to change them.
- If adding external scripts, styles, images, APIs, or WebSocket endpoints, update CSP in `custom/.lua/cms.lua`.

## Remove a Page

1. Remove the page entry from `custom/.lua/menu.json`.
2. Remove the fragment from `custom/.lua/www/`.
3. Remove page-specific files from `custom/static/` if no other page uses them.
4. Search for stale links to the removed page:

```bash
rg "RemovedPage.html|Removed Page" custom README.md doc/custom-design.md
```

## SMQ Design Rules

The `custom/` variant has CMS-level SMQ support. Page fragments must not create
their own SMQ client.

Do not do this in a page:

```js
const smq = SMQ.Client("/SMQ/");
```

Use `window.cmsSmq.mountPage(...)` instead.

The full shell creates one SMQ client through `custom/static/cms-smq.js`.
HTMX swaps only `#main`, so the shell-level SMQ connection remains open across
fragment navigation. Full page reloads create a new shell and a new SMQ
connection.

Server-side broker code is in `custom/.preload`. The browser endpoint is
`custom/SMQ/index.lsp`.

## SMQ Page Scope API

Use a page scope when a fragment needs SMQ:

```js
window.cmsSmq.mountPage("Diagnostics", (scope) => {
  scope.subscribeToEvent("DeviceState", onDeviceState);
  scope.subscribeToDirectMessage("DiagnosticsResp", onDiagnosticsResp);

  scope.onReady(() => {
    scope.sendToBroker("DiagnosticsReq", {});
  });

  scope.onReady(async () => {
    const status = await scope.rpc.getDeviceStatus();
    renderDeviceStatus(status);
  });

  scope.onCleanup(() => {
    stopTimers();
    removePageListeners();
  });
});
```

The scope API maps to native SMQ like this:

- `scope.subscribeToEvent(eventName, handler)`
  - Native shape: `smq.subscribe(eventName, {datatype:"json", onmsg:handler})`.
  - Use for one-to-many broadcast state/events.

- `scope.subscribeToDirectMessage(messageName, handler)`
  - Native shape: `smq.subscribe("self", messageName, {datatype:"json", onmsg:handler})`.
  - Use for one-to-one direct responses or commands addressed to this browser's ephemeral TID.

- `scope.sendToBroker(messageName, payload)`
  - Native shape: `smq.pubjson(payload, 1, messageName)`.
  - Use for requests/commands that the broker should validate and handle.
  - Prefer this for production dashboard/device workflows.

- `scope.sendToPeer(peerTid, messageName, payload)`
  - Native shape: `smq.pubjson(payload, peerTid, messageName)`.
  - Use only when the page has a valid destination TID and direct browser-to-peer messaging is intentional.

- `scope.publishEvent(eventName, payload)`
  - Native shape: `smq.pubjson(payload, eventName)`.
  - This is one-to-many publish.
  - Use for simple demos or trusted broadcast events. For authoritative state changes, prefer sending to the broker and letting the broker publish validated state.

- `scope.callRpc(methodName, ...args)`
  - Native shape: `smq.pubjson({id, name:methodName, args}, 1, "$RpcReq")` plus a direct `"$RpcResp"` response.
  - Use for page-specific request/response flows where Promise-style code or concurrent requests are useful.

- `scope.rpc.methodName(...args)`
  - Proxy for `scope.callRpc("methodName", ...args)`.
  - Prefer this when the page reads naturally as `await scope.rpc.getDeviceStatus()`.

- `scope.onReady(callback)`
  - Runs after the page's subscription barrier has been acknowledged.
  - Use for initial-state requests.

- `scope.onCleanup(callback)`
  - Runs when HTMX unloads the page fragment.
  - Use for page-owned timers, event listeners, and local resources.

## SMQ Page Lifecycle

When a page fragment loads:

1. The page script calls `window.cmsSmq.mountPage(...)`.
2. Any previous page scope is cleaned up.
3. The new page scope subscribes to event topics and direct `"self"` subtopics.
4. `cms-smq.js` schedules a final `$cmsReady` subscription barrier.
5. `scope.onReady(...)` callbacks run after the barrier is acknowledged.
6. The page requests initial state or sends startup messages.

When HTMX replaces `#main`:

1. `cms-smq.js` receives `htmx:beforeSwap`.
2. The active page scope is marked inactive.
3. `scope.onCleanup(...)` callbacks run.
4. Page-owned handlers are removed.
5. Page-owned event topics are unsubscribed when no handlers remain.
6. The shell-level SMQ connection stays open.

On SMQ reconnect:

1. `cms-smq.js` increments an internal connection generation.
2. Active page routes are resubscribed.
3. The readiness barrier runs again.
4. `scope.onReady(...)` can request fresh initial state.

Pending page RPC calls are rejected when the fragment unloads or when SMQ
disconnects. Do not leave page code waiting for old RPC responses after HTMX
navigation or reconnect.

## Page-Scoped RPC Pattern

Use the RPC pattern from `SMQ-examples/RPC` when a page needs asynchronous
request/response calls on top of the existing SMQ connection.

Browser page code:

```js
window.cmsSmq.mountPage("Diagnostics", (scope) => {
  scope.onReady(async () => {
    try {
      const rows = await scope.rpc.searchSites("main");
      renderRows(rows);
    } catch (error) {
      renderError(error.message);
    }
  });
});
```

The page scope sends this request shape to the broker:

```js
{ id: "...", name: "searchSites", args: ["main"] }
```

The request is sent directly to broker TID `1` on subtopic `"$RpcReq"`.
The broker replies directly to the browser on subtopic `"$RpcResp"`:

```js
{ id: "...", rsp: rows, err: null }
```

Use RPC when:

- a page can have multiple concurrent request/response calls;
- `async` / `await` makes page code clearer;
- the operation maps naturally to a small broker-side method;
- payloads are small or medium-sized.

Do not use RPC for:

- broadcast state that many clients should observe; use `scope.subscribeToEvent(...)`;
- device commands that need long workflows; use explicit broker-mediated messages;
- large payloads or file transfer; use HTTP/REST.

## Broker-Side SMQ Pattern

Register broker handlers in `custom/.preload`.

Direct request from browser to broker:

```lua
smq:subscribe("self", {
   subtopic = "DiagnosticsReq",
   json = true,
   onmsg = function(data, ptid)
      smq:publish({ok=true}, ptid, "DiagnosticsResp")
   end
})
```

Broadcast validated state:

```lua
smq:publish({state="ready"}, "DeviceState")
```

Use the exact Lua publish signatures:

```lua
smq:publish(data, "topic")          -- one-to-many broadcast
smq:publish(data, ptid, "subtopic") -- one-to-one direct
```

For production-like features, prefer broker-mediated flows:

1. Browser calls `scope.sendToBroker("SomeReq", payload)`.
2. Broker validates the request.
3. Broker replies with `smq:publish(response, ptid, "SomeResp")` or broadcasts with `smq:publish(state, "SomeState")`.

For page-scoped RPC, register a Lua function in the `rpcInterface` via
`registerRpcMethod(...)` in `custom/.preload`:

```lua
registerRpcMethod("getDeviceStatus", function()
   return {online=true}
end)
```

The CMS broker handles `"$RpcReq"` and `"$RpcResp"` correlation. Page scripts
call `await scope.rpc.getDeviceStatus()` and do not publish raw `"$RpcReq"`
messages themselves.

Avoid direct browser-to-device commands unless the design explicitly allows
peer-to-peer messaging and authorization is handled elsewhere.

## Native JavaScript Requirements

Custom variant JavaScript should be modern native JavaScript, unless the user asks to use a library such as Alpine.js.

- Prefer `querySelector`, `addEventListener`, `classList`, `fetch`, and standard browser APIs.
- Page scripts should tolerate direct full-page loads and HTMX fragment loads.
- Page scripts should run after the DOM elements they reference exist.

If a third-party library is required, prefer local files under `custom/static/`.
If an external CDN is required, update CSP in `custom/.lua/cms.lua`.

## Verification Checklist

After changes, run the app:

```bash
mako -l::custom
```

Check these paths:

- Direct full page load: `/SomePage.html`.
- HTMX navigation from the menu.
- Browser back/forward.
- If SMQ is involved, full reload plus HTMX navigation away from and back to the page.
- If styling changed, desktop and mobile nav widths.

Useful command checks:

```bash
node --check custom/static/ui.js
node --check custom/static/cms-smq.js
node --check custom/static/PageScript.js
```

Expected SMQ rule:

- `SMQ.Client(...)` should appear only in `custom/static/cms-smq.js`.

Expected response behavior:

- normal browser requests return a full shell;
- HTMX requests return fragments;
- `HX-History-Restore-Request` returns a full shell.

If the task is deployment-oriented, create or verify a ZIP of exactly one
selected variant directory and confirm the ZIP root contains the app files
directly.

## Packaging and Xedge Deployment

All dashboard variants can run under Mako Server or Xedge, but package exactly
one variant at a time. Do not package the whole `Light-Dashboard/` directory and
do not package multiple variants together. A ZIP containing `custom/`, `www/`,
and `htmx/` together is not a runnable Xedge application.

During development, run the selected variant directly:

```bash
mako -l::custom
```

For deployment, create a ZIP from inside the selected variant directory so the
ZIP root contains the app files directly. For example, to package `custom/`:

```bash
cd custom
zip -D -q -u -r -9 ../custom.zip .
```

Use the same pattern for the other variants:

```bash
cd htmx
zip -D -q -u -r -9 ../htmx.zip .
```

```bash
cd www
zip -D -q -u -r -9 ../www.zip .
```

The `.` at the end is important: it packages the contents of the current
variant directory. The ZIP must not contain a top-level `custom/`, `htmx/`, or
`www/` folder.

When packaging `custom/`, the ZIP should include the complete app contents at
the ZIP root, including:

- `.preload`
- `.lua/`
- `SMQ/`
- `static/`

The `zip` command must include hidden files and directories such as `.preload`
and `.lua/`. The documented command above does this.

For Xedge deployment, upload the variant ZIP to Xedge and let Xedge deploy it
on the target. See:

https://realtimelogic.com/articles/Mastering-Xedge-Application-Deployment-From-Installation-to-Creation

### Optional Xedge `.config`

A deployable Xedge ZIP may include a `.config` file when the app should install
with Xedge metadata such as name, URL directory, autostart behavior, or upgrade
handling.

Do not add `.config` automatically unless the user asks for an Xedge-ready
deployment package. If a `.config` file is requested, keep it variant-specific
and place it at the ZIP root alongside `.preload`.

A typical `.config` can return a Lua table with fields such as:

- `install`
- `upgrade`
- `autostart`
- `startprio`
- `name`
- `dirname`

Use `dirname=""` only when the app should run as the root application.
Otherwise set `dirname` to the desired URL path.

### Packaging Verification

After creating a ZIP, verify that the ZIP root contains app files directly, not
a nested variant directory.

Good:

```text
.preload
.lua/
SMQ/
static/
```

Bad:

```text
custom/.preload
custom/.lua/
custom/SMQ/
custom/static/
```

If the ZIP is nested like the bad example, recreate it by running the `zip`
command from inside the selected variant directory.

## Common Mistakes

- Creating a new SMQ client inside a page fragment.
- Disconnecting SMQ in page cleanup.
- Requesting initial state before direct-message subscriptions are ready.
- Forgetting to add a new page to `menu.json`.
- Changing nav classes without updating `ui.js`.
- Returning fragments for HTMX history-restore requests.
- Loading page scripts before the DOM they use.
- Adding query-string cache busters to reusable template assets.
- Adding external scripts/styles without updating CSP.
