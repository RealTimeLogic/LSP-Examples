# Custom Dashboard CMS Design

This document explains how the `custom/` dashboard variant works. The custom
variant is the most complete example in this directory: it combines a small
database-free CMS, HTMX fragment navigation, a two-level menu, native
JavaScript UI code, and CMS-level SMQ support.

The design goal is to behave like a lightweight single-page application when
JavaScript is available, while still behaving like a normal server-rendered CMS
when JavaScript is disabled or a page is opened directly.

## Design Goals

- Keep the application usable without a database.
- Keep page routing in `menu.json`, not in scattered conditionals.
- Let direct browser requests return complete HTML pages.
- Let HTMX requests return only page fragments.
- Preserve the shared page shell during HTMX navigation.
- Keep one SMQ connection alive while HTMX swaps page fragments.
- Make page-specific SMQ subscriptions temporary and easy to clean up.
- Use modern native JavaScript in `custom/`.

## File Map

- `custom/.preload`
  - Application bootstrap.
  - Loads the CMS engine from `custom/.lua/cms.lua`.
  - Creates the SMQ broker.
  - Registers broker-side demo handlers for the slider page.
  - Exposes `connectSmqClient(request)` for the SMQ endpoint.

- `custom/.lua/cms.lua`
  - Main CMS engine.
  - Loads and indexes `menu.json`.
  - Parses and caches `template.lsp`.
  - Routes requests for page fragments in `custom/.lua/www/`.
  - Chooses full-page rendering vs fragment rendering.
  - Handles HTMX history-restore requests safely.
  - Applies default security headers and compressed responses.
  - Installs optional form authentication when TPM support is available.

- `custom/.lua/menu.json`
  - Source of truth for pages shown in the navigation menu.
  - Supports nested groups through `children`.
  - Supports auth-gated items with `"auth": true`.

- `custom/.lua/www/template.lsp`
  - Shared HTML shell.
  - Emits the two-level navigation menu.
  - Loads HTMX, `/rtl/smq.js`, `custom/static/cms-smq.js`, and
    `custom/static/ui.js`.
  - Marks `#main` with `hx-history-elt`.
  - Calls `lspPage(...)` to inject the current page fragment.

- `custom/.lua/www/*.html`
  - Page fragments.
  - Can contain static HTML, LSP, page-specific CSS links, and page-specific
    scripts.
  - Should use `.header` and `.content` wrappers for consistent layout.

- `custom/static/ui.js`
  - Native JavaScript for menu toggling and navigation state.
  - Syncs active menu items after HTMX navigation and browser history restore.

- `custom/static/cms-smq.js`
  - Native JavaScript SMQ connection manager.
  - Owns the browser SMQ client for the full page shell.
  - Provides scoped page APIs for subscribing, sending broker messages, and
    cleaning up when a fragment unloads.

- `custom/SMQ/index.lsp`
  - SMQ browser endpoint.
  - Accepts SMQ upgrade requests.
  - Rejects ordinary HTTP requests.

## Startup Flow

Run the variant with:

```bash
mako -l::custom
```

Startup flow:

1. Mako loads `custom/.preload`.
2. `.preload` runs `io:dofile(".lua/cms.lua", app)`.
3. `cms.lua` installs the CMS directory callback into the resource tree.
4. `.preload` creates the SMQ broker with `require"smq.hub".create(...)`.
5. `.preload` registers broker-side handlers such as `setSlider` and
   `getSlider`.
6. Static resources are served by the normal resource reader.
7. Requests not matched by static resources fall through to the CMS callback.

The static resource reader stays ahead of the CMS callback. That means files in
`custom/static/`, `/rtl/smq.js`, and `custom/SMQ/index.lsp` can be served before
the CMS tries to resolve a request as a page.

## Request Routing

The CMS callback is `cmsfunc(_ENV, relpath, notInMenuOK)` in
`custom/.lua/cms.lua`.

The request flow is:

1. Normalize directory requests:
   - `/` becomes `index.html`.
   - Paths ending in `/` become `.../index.html`.
2. Check `menuT` to see if the requested page is registered in `menu.json`.
3. If the page is not registered:
   - Non-HTML paths return `false` so the default resource handling can finish.
   - HTML paths return the CMS `404.html` fragment with status `404`.
4. Fetch or create the per-page persistent table from `pagesT`.
5. Enable compressed output with `response:setresponse()`.
6. Parse the requested page with `parseLspPage(".lua/www/" .. relpath)`.
7. Return either:
   - the page fragment only, for ordinary HTMX requests, or
   - the full template shell, for normal requests and HTMX history restores.

The key branch is:

```lua
if hxRequest and not hxHistoryRestore then
   lspPage(_ENV, relpath, io, pageT, app)
else
   _ENV.menuL = menuL
   _ENV.menuT = menuT
   _ENV.relpath = relpath
   _ENV.lspPage = lspPage
   templatePage(_ENV, relpath, io, pageT, app)
end
```

This is what lets the same URL support both normal page loads and HTMX fragment
loads.

## Full Page vs Fragment Responses

Normal browser request:

```text
GET /form.html
HX-Request: absent
```

The CMS returns a complete HTML document:

- `<!doctype html>`
- `<head>` assets
- navigation shell
- `#main`
- injected page fragment
- shell scripts

HTMX navigation request:

```text
GET /form.html
HX-Request: true
```

The CMS returns only the page fragment from `custom/.lua/www/form.html`.
HTMX swaps that fragment into `#main`.

HTMX history-cache-miss request:

```text
GET /form.html
HX-Request: true
HX-History-Restore-Request: true
```

The CMS returns a complete HTML document. This matters because HTMX history
restore may need to rebuild a full page snapshot. Returning only a fragment in
this case can leave the browser with no shell, no menu, and no shell scripts.

## Template Shell

`custom/.lua/www/template.lsp` is the persistent shell for full page loads.

It is responsible for:

- computing the active menu item from `menuT[relpath]`;
- checking whether the user is authenticated with `request:user()`;
- rendering top-level and nested menu items;
- applying `hx-get`, `hx-push-url`, and `hx-target="#main"` to page links;
- loading shell-level CSS and JavaScript;
- creating the `#main` swap target;
- injecting the current fragment by calling `lspPage(...)`.

The `#main` element is marked with:

```html
<div id="main" class="main-pane" hx-history-elt>
```

This tells HTMX that the history snapshot should be based on the main content
area, not the entire document body. The shell remains responsible for
navigation, SMQ, and app-level scripts.

## Menu Model

`custom/.lua/menu.json` supports two shapes.

Top-level page:

```json
{ "name": "Home", "href": "index.html" }
```

Nested group:

```json
{
  "name": "Examples",
  "children": [
    { "name": "HTML Form", "href": "form.html" },
    { "name": "WebSockets", "href": "RoundSlider.html" }
  ]
}
```

The CMS recursively walks `menu.json` and builds `menuT`, a lookup table keyed
by `href`. A page must be registered in `menu.json` unless the caller invokes
`cmsfunc(..., notInMenuOK)` for a special internal page such as login.

The template also uses `auth` flags:

```json
{ "name": "Sign Out", "href": "logout.html", "auth": true }
```

Items with `"auth": true` are emitted only when `request:user()` is present.

## Navigation JavaScript

`custom/static/ui.js` is native JavaScript. It handles three jobs.

First, it toggles the responsive menu:

- clicking `#menuLink` toggles `active` on the layout, menu, and menu link;
- clicking outside an open mobile menu closes it.

Second, it toggles menu groups:

- group labels rendered as `<span class="nav-group-title">` expand/collapse
  their child list with `is-open`;
- active groups use `is-active`.

Third, it keeps navigation state synchronized:

- after an HTMX request, it marks the clicked link as active;
- on `htmx:historyRestore`, it finds the menu link matching the restored URL;
- on `popstate`, it schedules the same URL-based synchronization;
- it updates `document.title` from the active link text.

This is needed because HTMX swaps only `#main`. The menu itself is outside the
swap target, so it must be updated by shell-level JavaScript.

## SMQ Overview

The `custom/` variant treats SMQ as part of the CMS shell.

The important split is:

- The full page shell owns the browser SMQ connection.
- Page fragments own only temporary subscriptions and UI handlers.
- The broker owns validation and shared server state.

This means:

- a normal full page load creates a new SMQ connection;
- HTMX page navigation keeps the existing SMQ connection alive;
- fragment unload removes page-owned handlers and subscriptions;
- page scripts do not call `SMQ.Client()` directly.

## Server-Side SMQ

`custom/.preload` creates the broker:

```lua
smq = require"smq.hub".create{
   onconnect = newClient,
   onclose = clientDisconnected
}
```

It then registers broker-side handlers. The slider demo uses:

```lua
smq:subscribe("self", {
   subtopic = "setSlider",
   json = true,
   onmsg = function(data)
      ...
      smq:publish({angle=angle}, "slider")
   end
})

smq:subscribe("self", {
   subtopic = "getSlider",
   onmsg = function(data, ptid)
      smq:publish({angle=angle}, ptid, "slider")
   end
})
```

The route is broker-mediated:

- browser sends `setSlider` directly to broker TID `1`;
- broker validates and stores the angle;
- broker broadcasts validated state on the `slider` topic;
- browser sends `getSlider` directly to broker TID `1`;
- broker replies directly to the requesting browser on `"self"` subtopic
  `slider`.

The browser SMQ endpoint is `custom/SMQ/index.lsp`. It does not contain
application behavior. It only checks whether the request is an SMQ request and
passes it to the broker:

```lua
if hub.isSMQ(request) then
   app.connectSmqClient(request)
   response:abort()
end

response:senderror(400, "Not an SMQ connection request")
```

Rejecting ordinary HTTP requests keeps crawlers, direct browser navigation, and
mistaken fetches from entering the SMQ upgrade path.

## How custom/static/cms-smq.js Works

`custom/static/cms-smq.js` is loaded by `template.lsp` on every full page load.
It creates exactly one browser SMQ client for that shell:

```js
const smq = SMQ.Client("/SMQ/", { cleanstart: true });
```

`cleanstart: true` means the code explicitly rebuilds subscriptions after a
reconnect. This keeps reconnect behavior controlled by the CMS scaffold instead
of relying on implicit retained client state.

The module exposes `window.cmsSmq` with these main members:

- `client`
  - the raw SMQ client, exposed for low-level cases;
- `brokerTid`
  - currently `1`, the default broker TID;
- `isConnected()`
  - reports whether the shell-level SMQ client is connected;
- `sendToBroker(messageName, payload)`
  - sends JSON directly to the broker using `brokerTid` and `messageName` as
    subtopic;
- `sendToPeer(peerTid, messageName, payload)`
  - sends JSON directly to another peer TID;
- `publishEvent(eventName, payload)`
  - publishes JSON to a one-to-many topic;
- `mountPage(name, init)`
  - creates a page scope for the current fragment;
- `cleanupPage()`
  - tears down the current page scope.

### Route Table

Internally, `cms-smq.js` keeps a route table:

```js
const routes = new Map();
```

Each route is keyed by topic and optional subtopic:

```js
function routeKey(topic, subtopic) {
  return `${topic}\u001f${subtopic || ""}`;
}
```

A route stores:

- `topic`
- `subtopic`
- `datatype`
- `handlers`
- `subscribedGeneration`

`handlers` is a map of page-scope IDs to callback functions. This lets one SMQ
subscription fan out to all active handlers for that route. In the current CMS
there is normally only one active page scope, but the route table is still
structured so ownership is explicit.

### Page Scopes

Page scopes are the way a fragment opts into SMQ. A scope groups the
fragment's SMQ subscriptions, initial-state requests, and teardown callbacks so
they can be installed when the fragment loads and removed when HTMX replaces
`#main`.

Page scripts call:

```js
window.cmsSmq.mountPage("PageName", (scope) => {
  ...
});
```

The scope gives the page a controlled API:

```js
scope.subscribeToEvent("TopicName", handler);
scope.subscribeToDirectMessage("ResponseName", handler);
scope.sendToBroker("RequestName", payload);
scope.sendToPeer(peerTid, "MessageName", payload);
scope.publishEvent("EventName", payload);
scope.callRpc("methodName", arg1, arg2);
scope.rpc.methodName(arg1, arg2);
scope.onReady(callback);
scope.onCleanup(callback);
```

Most helpers are thin wrappers around the native SMQ JavaScript API. The RPC
helpers add the small `$RpcReq` / `$RpcResp` correlation layer documented
below. In both cases, the page-scope API makes the route explicit and keeps
page-owned work tied to the fragment lifecycle.

| Scope helper | Native SMQ shape | Route type | Use when |
| --- | --- | --- | --- |
| `scope.subscribeToEvent(eventName, handler)` | `smq.subscribe(eventName, {datatype:"json", onmsg:handler})` | one-to-many receive | The page wants broadcast state or events that any interested client may observe. |
| `scope.subscribeToDirectMessage(messageName, handler)` | `smq.subscribe("self", messageName, {datatype:"json", onmsg:handler})` | one-to-one receive | The page expects a direct response or command addressed to this browser's ephemeral TID. |
| `scope.sendToBroker(messageName, payload)` | `smq.pubjson(payload, 1, messageName)` | one-to-one send to broker | The page is making a request or command that the broker should validate and handle. This is the preferred pattern for managed device/dashboard workflows. |
| `scope.sendToPeer(peerTid, messageName, payload)` | `smq.pubjson(payload, peerTid, messageName)` | one-to-one send to peer | The page intentionally sends directly to a known peer TID. Use this for peer-to-peer demos or broker-approved direct flows, not for privileged device commands that need broker authorization. |
| `scope.publishEvent(eventName, payload)` | `smq.pubjson(payload, eventName)` | one-to-many send | The page intentionally broadcasts an event to all subscribers of that topic. Use this for simple demos or trusted events; for production state changes, prefer `sendToBroker(...)` and let the broker publish validated state. |
| `scope.callRpc(methodName, ...args)` | `smq.pubjson({id,name,args}, 1, "$RpcReq")` and `"$RpcResp"` on `"self"` | correlated request/reply | The page needs Promise-style request/response, especially when multiple requests may be in flight. |
| `scope.rpc.methodName(...args)` | proxy for `scope.callRpc("methodName", ...args)` | correlated request/reply | Same as `callRpc`, but reads like a normal async method call. |

In other words, `publishEvent("EventName", payload)` is the one-to-many path.
It maps to SMQ publish-by-topic. `sendToPeer(peerTid, "MessageName", payload)`
is the direct one-to-one path. `sendToBroker(...)` is just a convenience wrapper
for the most common direct path: send to broker TID `1` and use the message name
as the SMQ subtopic.

When a page mounts:

1. any previous page scope is cleaned up;
2. a new scope gets a unique ID;
3. the page's `init(scope)` callback runs;
4. route subscriptions are installed;
5. the readiness barrier is scheduled.

### Page-Scoped RPC

The custom CMS also includes the SMQ RPC pattern used by
`SMQ-examples/RPC`. This is still SMQ direct messaging; it adds a small
correlation layer so page code can use Promises and `async` / `await`.

The browser side is page-scoped:

```js
window.cmsSmq.mountPage("Diagnostics", (scope) => {
  scope.onReady(async () => {
    try {
      const status = await scope.rpc.getDeviceStatus();
      renderDeviceStatus(status);
    } catch (error) {
      renderError(error.message);
    }
  });
});
```

`scope.rpc.getDeviceStatus()` sends a direct JSON message to the broker on
`"$RpcReq"`:

```js
{
  id: "Diagnostics:...:1",
  name: "getDeviceStatus",
  args: []
}
```

The broker replies directly to the browser on `"$RpcResp"` with the same `id`:

```js
{ id: "...", rsp: result, err: null }
```

`cms-smq.js` keeps pending RPC calls in the active page scope. When a matching
response arrives, the Promise resolves with `rsp` or rejects with `err`. When
HTMX unloads the fragment or the SMQ connection closes, pending page RPC calls
are rejected so callers do not wait forever.

Use RPC for page-specific request/response operations such as loading a
filtered table, requesting diagnostics, or invoking a small broker-side method.
Use `subscribeToEvent(...)` for shared state that many pages or clients should
observe. Use `sendToBroker(...)` and `subscribeToDirectMessage(...)` for simple
one-off command/reply flows where a named response subtopic is clearer than a
method call.

On the server side, `custom/.preload` registers broker RPC methods in the
`rpcInterface` table through `registerRpcMethod(...)`. The broker handler
listens for `"$RpcReq"`, validates the request, calls the registered Lua
function with the supplied args, and publishes the correlated `"$RpcResp"`
directly back to the requester.

### Subscriptions

`subscribeToEvent(...)` subscribes to a one-to-many topic:

```js
scope.subscribeToEvent("slider", applyServerValue);
```

`subscribeToDirectMessage(...)` subscribes to a `"self"` subtopic:

```js
scope.subscribeToDirectMessage("slider", applyServerValue);
```

Both call `ensureRoute(...)`, which creates or updates the route table entry and
then calls `subscribeRoute(...)`.

`subscribeRoute(...)` calls the raw SMQ API:

```js
smq.subscribe(route.topic, route.subtopic, settings);
```

or, for a topic without subtopic:

```js
smq.subscribe(route.topic, settings);
```

The settings object includes `datatype`, normally `"json"`, and a single
`onmsg` dispatcher. The dispatcher loops through the route's page-owned
handlers and calls each handler.

### Readiness Barrier

Pages often need initial state. The page should not ask for that state until
its subscriptions are installed; otherwise direct responses can arrive before
the page has subscribed to the relevant `"self"` subtopic.

`cms-smq.js` uses one final harmless subscription as a barrier:

```js
smq.subscribe("$cmsReady", {
  onack(accepted) {
    ...
  }
});
```

SMQ processes subscription requests sequentially. When the `$cmsReady`
`onack` callback runs, the previous subscriptions requested by the page scope
have already been accepted or denied. At that point, `scope.onReady(...)`
callbacks can safely send initial-state requests.

Example:

```js
scope.onReady(() => {
  scope.sendToBroker("getSlider", {});
});
```

### Cleanup and HTMX Teardown

The shell listens for HTMX replacing `#main`:

```js
document.body.addEventListener("htmx:beforeSwap", (event) => {
  if (event.detail && event.detail.target && event.detail.target.id === "main") {
    window.cmsSmq.cleanupPage();
  }
});
```

`cleanupPage()` calls `cleanupScope(currentScope)`.

Cleanup does this:

1. marks the scope inactive;
2. runs callbacks registered with `scope.onCleanup(...)`;
3. removes the scope's handlers from each route;
4. deletes routes that no longer have handlers;
5. unsubscribes from page-owned event topics when no handlers remain;
6. leaves the shared SMQ connection open.

The code intentionally does not disconnect SMQ on fragment unload. The SMQ
connection belongs to the shell, not to the page fragment.

### Reconnect Handling

The SMQ client uses:

```js
smq.onconnect = onConnect;
smq.onreconnect = onConnect;
```

On the first connection, the scaffold marks the shell as connected.

On reconnect, it:

1. increments `connectionGeneration`;
2. resubscribes active routes for the current page scope;
3. runs the readiness barrier again;
4. lets the page re-request initial state from `scope.onReady(...)`.

The generation counter prevents stale readiness callbacks from an older
connection from running after a reconnect.

## Page Author Pattern for SMQ

A page that needs SMQ should:

1. Put the page markup in `custom/.lua/www/PageName.html`.
2. Load page-specific JavaScript after the DOM elements it needs.
3. Do not call `SMQ.Client()`.
4. Call `window.cmsSmq.mountPage(...)`.
5. Subscribe to all required topics and direct messages inside the mount
   callback.
6. Use `scope.onReady(...)` to request initial state.
7. Use `scope.onCleanup(...)` for timers, DOM listeners, or local resources.
8. Use `scope.sendToPeer(...)` only when the page has a valid destination TID
   and direct browser-to-peer messaging is part of the design. Otherwise send
   requests to the broker with `scope.sendToBroker(...)`.

Example:

```html
<div class="header">
  <h1>Diagnostics</h1>
</div>

<div class="content">
  <div id="DiagnosticsOutput"></div>
</div>

<script src="/static/Diagnostics.js"></script>
```

```js
(function (window, document) {
  "use strict";

  const output = document.getElementById("DiagnosticsOutput");

  window.cmsSmq.mountPage("Diagnostics", (scope) => {
    scope.subscribeToDirectMessage("DiagnosticsResp", (message) => {
      output.textContent = JSON.stringify(message);
    });

    scope.subscribeToEvent("DeviceState", (message) => {
      renderDeviceState(message);
    });

    scope.onReady(() => {
      scope.sendToBroker("DiagnosticsReq", {});
    });

    scope.onCleanup(() => {
      output.textContent = "";
    });
  });
}(this, this.document));
```

## RoundSlider Demo

`custom/.lua/www/RoundSlider.html` is a demo page for this model.

It contains:

- page-specific CSS: `/static/RoundSlider.css`;
- a native range input;
- a simple CSS-driven gauge;
- page-specific script: `/static/RoundSlider.js`.

The script:

1. finds the slider DOM elements;
2. disables the control if `window.cmsSmq` is unavailable;
3. renders local slider changes immediately;
4. sends `setSlider` to the broker for local changes;
5. subscribes to direct `"self"/"slider"` messages;
6. subscribes to broadcast `slider` events;
7. requests initial state with `getSlider` in `scope.onReady(...)`;
8. avoids echo loops by not republishing values that came from the server.

The broker in `.preload` owns the authoritative angle value for the demo. The
browser does not directly broadcast slider state; it asks the broker to set the
state, and the broker publishes the validated value.

## Authentication

Authentication is optional. If TPM support is present, `cms.lua` can install a
form authenticator dynamically when users exist in the encrypted user database.

The menu renderer checks `request:user()` and hides items marked with
`"auth": true` when the user is not authenticated.

If authentication is enabled, the SMQ connection is still created by the shell.
Production systems should extend the broker options to classify browser peers
by authenticated user and enforce authorization in broker callbacks.

## Security Headers and External Assets

Default security headers are set in `custom/.lua/cms.lua`:

```lua
local securityPolicies = {
   ["Content-Security-Policy"] =
      "default-src 'self'; script-src 'self' cdn.jsdelivr.net unpkg.com 'unsafe-inline'; style-src 'self' cdn.jsdelivr.net unpkg.com 'unsafe-inline'",
   ["X-Content-Type-Options"] = "nosniff",
}
```

If a page adds new external scripts, styles, images, APIs, or WebSocket
endpoints, update the CSP in `cms.lua`.

The example templates intentionally use plain asset paths such as:

```html
<script src="/static/ui.js"></script>
```

Do not add cache-busting query strings to the reusable examples. If a browser
cache interferes during local development, reload with cache disabled or restart
the browser session.

## Design Tradeoffs

This CMS is intentionally small:

- It does not use a database for page lookup.
- It parses page fragments on demand.
- It caches only the template function and per-page state tables.
- It uses `menu.json` as both navigation and routing policy.
- It keeps SMQ connection management in one shell-level script.

The tradeoff is that page authors must follow the page lifecycle:

- register pages in `menu.json`;
- keep page-specific SMQ work inside `mountPage(...)`;
- request initial state from `scope.onReady(...)`;
- clean page-owned timers and event listeners in `scope.onCleanup(...)`;
- avoid creating independent SMQ clients from page fragments.

Following this pattern keeps the CMS useful for embedded systems: simple full
page behavior still works, while HTMX and SMQ provide a richer real-time
experience when JavaScript is available.
