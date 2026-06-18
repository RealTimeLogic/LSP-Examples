# Light Dashboard Templates

## Overview

This directory contains three ready-to-run dashboard UIs for embedded devices such as routers, gateways, and firmware-backed products.

The dashboards are designed for small embedded targets, typically RTOS-based devices, running Xedge or a custom Barracuda App Server build. They avoid a database and keep the CMS layer file/menu driven, which makes them suitable for firmware-style products where the UI is bundled with the device software.

For larger platforms such as Embedded Linux and QNX, consider using the database-driven Mako Server Content Management System (CMS) instead.

#### The introductory article for this design:

- https://makoserver.net/articles/How-to-Build-an-Interactive-Dashboard-App

#### Variants
All three variants use the same CMS-style flow: `menu.json` defines the pages, `cms.lua` routes requests, and `template.lsp` renders the shared shell around each page fragment.

Available variants:

- `www/` - SSR + Pure.css
- `htmx/` - CSR/HTMX + Pure.css
- `custom/` - CSR/HTMX + custom CSS, two-level navigation, CMS-level SMQ support, and the default target for new work. This is the most complete and complex variant.

Authentication is optional and disabled by default. In the default `custom/` variant, user management is backed by a TPM-enabled encrypted user database when TPM support is available.

#### How to run using [Xedge](https://realtimelogic.com/products/xedge/)

When using Xedge, zip the selected variant, upload to Xedge, and unzip using the app uploader. See [Xedge Application Deployment](https://realtimelogic.com/articles/Mastering-Xedge-Application-Deployment-From-Installation-to-Creation) for details.

#### How to run using [Mako Server](https://makoserver.net/)


Run the SSR + Pure.css variant:

```bash
mako -l::www
```

Run the CSR/HTMX + Pure.css variant:

```bash
mako -l::htmx
```

Run the CSR/HTMX + custom CSS variant:

```bash
mako -l::custom
```

Then open `http://localhost:portno`.

Authentication behavior:

- Add at least one user on the `Users` page to enable authentication.
- Remove all users to disable authentication again.

## Files

- `custom/.lua/cms.lua`, `htmx/.lua/cms.lua`, `www/.lua/cms.lua` - Mini CMS/router for each variant.
- `custom/.lua/menu.json`, `htmx/.lua/menu.json`, `www/.lua/menu.json` - Menu and routing source of truth.
- `custom/.lua/www/template.lsp`, `htmx/.lua/www/template.lsp`, `www/.lua/www/template.lsp` - Shared layout shells.
- `custom/.lua/www/*.html`, `htmx/.lua/www/*.html`, `www/.lua/www/*.html` - Page fragments rendered inside the layout.
- `custom/static/`, `htmx/static/`, `www/static/` - Variant-specific CSS and JavaScript assets. In `custom/`, `cms-smq.js` owns the shared browser SMQ connection.
- `AGENTS.md` - Detailed file map and update guidance **[targeting AI](#ai-assisted-changes)**, with `custom/` as the default variant for new work.

## How it works

Each variant inserts a CMS directory function alongside the resource reader so that static assets still take precedence. The CMS callback:

1. resolves directory requests to `index.html`
2. checks whether the requested page exists in `menu.json`
3. loads the page fragment from `.lua/www/`
4. returns either the fragment alone for HTMX requests or the full `template.lsp` shell for normal requests
5. applies security headers and compressed responses

The `custom/` variant adds nested menu support through `children` arrays in `menu.json`, renders a two-level menu in the template, and includes SMQ as part of the CMS shell. If TPM support is available, the CMS also enables a form authenticator dynamically when at least one user exists in the encrypted user database.

### Why the variants differ

The [introductory article](#the-introductory-article-for-this-design) explains the tradeoffs in more detail, but the high-level split is:

- **SSR + Pure.css** for a classic server-rendered experience
- **CSR/HTMX + Pure.css** for fragment-based updates with a familiar CSS framework
- **CSR/HTMX + custom CSS** for the most flexible visual design, a two-level menu, and built-in SMQ scaffolding

The Pure.css SSR variant is the easiest to understand if you plan on studying the CMS engine.

The article also calls out a few practical details that matter in real products:

- HTMX requests return fragments, while full requests return the complete layout.
- Pages are composed dynamically at runtime from `template.lsp` plus the requested fragment.
- SSR navigation closes real-time connections. The `custom/` shell keeps one SMQ connection alive across HTMX fragment navigation, while full page reloads create a new shell and a new SMQ connection.
- Responses are compressed, and authentication can be layered in without changing each individual page.

### Add, modify, and remove pages

To add a new page:

1. Create a fragment in `.lua/www/`, for example `Diagnostics.html`:

```html
<div class="header">
  <h1>Diagnostics</h1>
</div>
<div class="content">
  ...
</div>
```

2. Register it in `.lua/menu.json`:

```json
{ "name": "Diagnostics", "href": "Diagnostics.html" }
```

For the `custom/` variant, you can also place it under a group:

```json
{
  "name": "System",
  "children": [
    { "name": "Diagnostics", "href": "Diagnostics.html" }
  ]
}
```

3. Apply the change in whichever variant or variants you want to keep in sync:

- `custom/.lua/www/`
- `www/.lua/www/`
- `htmx/.lua/www/`

To modify a page, update the fragment and adjust the matching menu entry if the label or location changes. To remove a page, delete the fragment and remove the matching entry from `.lua/menu.json`.

### Styling and UI behavior

- `www/` and `htmx/` use **Pure.css** for most of the layout and utility styling.
- `custom/` uses a custom CSS design with a two-level menu and is the most flexible choice if you want to align the UI with a specific brand.
- Global styles live in `static/styles.css`, and layout/menu behavior lives in `static/ui.js`.
- Keep page markup consistent by using the `.header` and `.content` wrappers already used by the included pages.


### SMQ in the custom CMS

The `custom/` variant treats SMQ as a CMS capability, not as something each page opens by itself.

On every full page load, `custom/.lua/www/template.lsp` loads `/rtl/smq.js` and `custom/static/cms-smq.js`. The shared `cms-smq.js` file creates one browser SMQ client connected to `/SMQ/`. When navigation happens through HTMX, only `#main` is replaced, so the page shell remains loaded and the SMQ connection stays open. When the browser performs a full reload or direct navigation, the old shell goes away and the new shell opens a fresh SMQ connection.

The server side is set up in `custom/.preload`. It creates the SMQ broker, registers broker-side handlers, and exposes the browser connection through `custom/SMQ/index.lsp`. The SMQ endpoint accepts real SMQ upgrade requests and rejects ordinary HTTP requests.

Pages that need SMQ should not call `SMQ.Client()` directly. Instead, a page script should mount itself with `window.cmsSmq.mountPage(...)`, subscribe to the topics it needs, request initial state after the subscription barrier completes, and register any cleanup it needs when the fragment unloads.

For page-specific request/response work, prefer the scoped RPC helper. It uses
the SMQ RPC pattern from `SMQ-examples/RPC`: requests go to `$RpcReq`, replies
return on `$RpcResp`, and each response is matched to the original Promise by a
correlation ID.

#### SMQ Page API

For the full page-scope API and how each helper maps to the underlying SMQ routing concepts, see [Custom CMS SMQ page scopes](doc/custom-design.md#page-scopes).

#### Example

Minimal page script pattern:

```js
window.cmsSmq.mountPage("Diagnostics", (scope) => {
  scope.subscribeToEvent("DeviceState", (message) => {
    renderDeviceState(message);
  });

  scope.subscribeToDirectMessage("DiagnosticsResp", (message) => {
    renderDiagnostics(message);
  });

  scope.onReady(() => {
    scope.sendToBroker("DiagnosticsReq", {});
  });

  scope.onReady(async () => {
    const status = await scope.rpc.getDeviceStatus();
    renderDeviceStatus(status);
  });

  scope.onCleanup(() => {
    stopLocalTimers();
    removePageOnlyEventListeners();
  });
});
```

The lifecycle is:

1. The full page shell opens the CMS SMQ connection.
2. A page fragment loads into `#main`.
3. The page script calls `mountPage(...)`.
4. The page subscribes to its event topics and `"self"` direct-message subtopics.
5. `scope.onReady(...)` runs after the final subscription barrier is acknowledged, so the page can safely request initial state.
6. When HTMX replaces `#main`, `cms-smq.js` tears down the active page scope, removes page-owned handlers, unsubscribes from page-owned event topics when no handlers remain, and runs `scope.onCleanup(...)`.
7. The CMS SMQ connection remains open until the full page shell unloads.

Use one-to-many event topics for state many pages or clients may observe. Use
the scoped RPC helper for page-specific request/response calls when the page may
have more than one request in flight or when Promise-style `async` / `await`
code is clearer. Use `scope.sendToBroker(...)` and
`scope.subscribeToDirectMessage(...)` only for simple one-off command/reply
flows where named messages are clearer than RPC methods.

## Notes / Troubleshooting

- For AI-assisted updates, see [AGENTS.md](AGENTS.md) and target `custom/` first unless you specifically want parity across all three variants ([details below](#ai-assisted-changes)).
- If you add new external scripts or styles, update the Content Security Policy in the relevant `cms.lua`.
- Keep page fragments wrapped in `.header` and `.content` for consistent styling across variants.

### Authentication

Authentication is intentionally optional:

- Add at least one user on the `Users` page to enable it.
- Add multiple users if needed.
- Remove a user by entering an existing username and leaving the password blank.
- Remove all users to disable authentication again.

### Security policies

Default security headers, including the Content Security Policy, are defined in `cms.lua`. If you add CDN assets or any new external scripts or styles, update the CSP to match.

### AI-assisted changes

This project is intentionally AI-friendly. AI can be used to modify any of the three variants:

- `custom/`: the default target for new work. It has the most complete CMS behavior, custom CSS, two-level navigation, HTMX fragment loading, and CMS-level SMQ support.
- `htmx/`: the Pure.css HTMX variant. Use it when you want a smaller HTMX reference implementation.
- `www/`: the Pure.css SSR variant. Use it when you want traditional full-page rendering.

Always tell the AI which variant to change. For new dashboard features, target `custom/` unless you specifically want parity across multiple variants.

This example comes with its [own AGENTS.md file](AGENTS.md). The `custom/` variant also has an agent-focused skill file: [doc/custom-skill.md](doc/custom-skill.md). Use it when asking an AI agent to work on the custom CMS, especially for layout and color changes, adding or removing pages, HTMX navigation, or SMQ page scopes.

If you are new to AGENTS.md and using AI agents, see the instructions for the [Blob Arena Game -> Using an AI Agent](../SMQ-examples/BlobArena/README.md#using-an-ai-agent).

Good AI prompts for this repo should include:

- the target variant (`custom/`, `htmx/`, `www/`, or all variants);
- whether the change is page content, layout/style, routing, server-side Lua/LSP, client-side JavaScript, or SMQ;
- any files that must or must not be changed;
- whether external scripts/styles are allowed;
- verification expectations, such as `mako -l::custom`, browser back/forward, or SMQ behavior.

For `custom/`, also tell the AI:

- use modern native JavaScript, not jQuery;
- keep the HTMX full-page vs fragment behavior intact;
- page scripts that need SMQ must use `window.cmsSmq.mountPage(...)`, not `SMQ.Client(...)`;
- see [Custom CMS SMQ page scopes](doc/custom-design.md#page-scopes) for the SMQ page lifecycle.

### Example AI prompts

The prompts below are intentionally detailed because real dashboard changes often span layout, CSS, runtime behavior, routing, security headers, and sometimes SMQ.

#### UI style change for the custom theme

You can use AI to change the theme of any variant, but `custom/` is usually the best starting point because it has the richest layout and styling surface. This prompt assumes a screenshot from a Schneider Electric embedded web server is provided as the visual reference.

```text
Target variant: custom/
Use AGENTS.md and doc/custom-skill.md.

Update the custom dashboard theme to match the look and feel of the
provided Schneider Electric embedded UI screenshot.

Requirements
- Match the screenshot's overall theme: colors, contrast, spacing, typography feel, and component styling.
- Keep the existing layout, two-level menu, and HTMX behavior intact.
- Keep browser back/forward navigation working.
- Replace the top-left "Company" brand text with the logo in custom/static/se-logo.svg if that file exists.
- Keep the logo sized to fit the nav height and width.
- Use the existing CSS variables in custom/static/styles.css where possible.

Scope
- Modify only files under custom/.
- Update custom/static/styles.css for palette, typography, nav, buttons, panels, forms, and focus states.
- Update custom/.lua/www/template.lsp only if the shell structure or brand/logo slot needs it.
- Do not change page content, routing, menu structure, or SMQ behavior.

Notes
- Use modern native JavaScript only if JavaScript changes are needed.
- Prefer local assets. If external assets are required, call them out and update CSP in custom/.lua/cms.lua.
- After changes, run mako -l::custom and verify direct loads, HTMX navigation, and browser back/forward.
```

Reference image:

![Schneider Electric UI](https://makoserver.net/blogmedia/dashboard/se.jpg)

#### Add an SMQ-powered custom page

The `custom/` variant already has a persistent shell-level SMQ connection in `custom/static/cms-smq.js`. Page fragments should only register the subscriptions, initial requests, and cleanup they need while loaded.

Use this pattern when adding a page that needs live data:

```text
Target variant: custom/
Use AGENTS.md, doc/custom-skill.md, and doc/custom-design.md.

Create a new Diagnostics page that uses the existing CMS-level SMQ connection.

Requirements
- Add custom/.lua/www/Diagnostics.html with .header and .content wrappers.
- Add custom/static/Diagnostics.js and custom/static/Diagnostics.css if needed.
- Register the page in custom/.lua/menu.json.
- Use window.cmsSmq.mountPage("Diagnostics", function(scope) { ... }).
- Do not call SMQ.Client(...) from the page script.
- Subscribe to broker-published state with scope.subscribeToEvent(...).
- Subscribe to direct replies with scope.subscribeToDirectMessage(...).
- Request initial state in scope.onReady(...), after subscriptions are ready.
- For page-specific request/response calls, use await scope.rpc.methodName(...) or scope.callRpc("methodName", ...args).
- Register DOM timers/listeners with scope.onCleanup(...) when cleanup is needed.
- Let cms-smq.js clean up SMQ subscriptions when HTMX unloads the fragment.

Behavior details
- The SMQ connection must stay alive across HTMX navigation.
- The page must not leave stale subscriptions or timers behind.
- Direct full-page loads and HTMX fragment loads must both work.
- Browser back/forward must keep working.

JavaScript constraints
- Use modern native JavaScript.

Page-specific SMQ contract
- Define the page-level message names the page needs, for example DiagnosticsReq, DiagnosticsResp, and DeviceState.
- Page code should request broker work with scope.sendToBroker("DiagnosticsReq", payload).
- Page code should receive direct broker replies with scope.subscribeToDirectMessage("DiagnosticsResp", handler).
- Page code should receive shared state broadcasts with scope.subscribeToEvent("DeviceState", handler).
- For request/response flows with concurrent requests, define RPC methods and call them with scope.rpc.methodName(...). The page scope handles $RpcReq/$RpcResp correlation and rejects pending RPC calls when the fragment unloads or SMQ disconnects.
- If new broker RPC behavior is needed, add methods in custom/.preload with registerRpcMethod("methodName", function(...) ... end).
- If the page needs named command/reply messages instead of RPC, define those page-level message names and implement the broker handling in custom/.preload. Page scripts should still use the page-scope helpers.

Verification
- Run mako -l::custom.
- Verify direct load, HTMX navigation, browser back/forward, and navigating away from and back to the page.
- Run node --check on changed JavaScript files.
```

#### Solar dashboard prompt

This more advanced prompt creates a full solar dashboard page, including charting, live data, server-side publishing, and CSP updates. It shows how a single feature request can affect:

- menu registration
- page fragments
- CSS and JavaScript
- real-time subscriptions
- server-side simulation data
- security headers

Reference image:

![Solar Dashboard](https://makoserver.net/blogmedia/dashboard/solar.jpg)

An optimized prompt for the current `custom/` variant:

```text
Task: Create Solar Dashboard Page

Target variant: custom/
Use AGENTS.md, doc/custom-skill.md, and doc/custom-design.md.

Create a new solar dashboard page using vanilla HTML/CSS/JS, inspired
by the provided screenshot: dark industrial UI, two top cards, and one
large bottom bar chart. Use a warm gold accent for primary numbers and
bars, light gray for labels, and charcoal/black surfaces with subtle
depth.

- Page fragment: solar.html
- JS: solar.js
- CSS: solar.css

Menu

- Add a new top-level menu item at the end of custom/.lua/menu.json:
  { "name": "Solar", "href": "solar.html" }

Libraries

- Use Apache ECharts from a CDN.
- No frameworks/build tools.
- Do not use external icon libraries; use inline SVG or basic shapes.
- solar.js must be modern native JavaScript only.
- Update CSP in custom/.lua/cms.lua for any external endpoints or CDN assets.

Layout / Components

1. Card 1: Energy Today
   - Big number: 93.07 kWh (example)
   - Smaller line: Lifetime: 143.69 MWh
   - Circular ECharts gauge showing 18.7 kW (example)
   - Include a thin "timeline" indicator (HTML/CSS is fine)
2. Card 2: Weather
   - Big number: 52 F
   - Label: Broken Clouds
   - Smaller line: October 13, 2022 02:18 pm
   - Simple cloud icon via inline SVG
   - The temperature must be updated using real-time data from Open-Meteo
3. Bottom chart: Daily kWh bars
   - Full-width ECharts bar chart
   - X-axis = days, Y-axis = kWh
   - Muted grid lines, gold/yellow bars, dark chart background
   - Rounded container

Responsive layout

- Two cards in a row on the desktop
- Stack cards on small screens

Design

- Dark gradient background
- Rounded cards
- Subtle inner shadows
- Big numeric typography
- Warm gold accent for primary numbers/bars
- Light gray for labels

Client Data Model + Updates

- Put all values into a single JS object named solarData.
- Implement renderDashboard(solarData) to update DOM text and call setOption on both charts.
- Handle window resize with chart.resize().

Weather Data

- Use the Open-Meteo endpoint to retrieve the current temperature, weather code, and time/date.
- Automatic location detection:
  1. Try browser geolocation (permission prompt)
  2. If denied/unavailable, use IP-based geolocation via https://ipapi.co/json/
  3. If both fail, fallback to default coordinates:
     - Latitude: 33.53194
     - Longitude: -117.7025

SMQ Updates

- Reuse the persistent window.cmsSmq created by custom/static/cms-smq.js.
- Do not create a new SMQ client and do not call SMQ.Client(...) in solar.js.
- Mount the page with window.cmsSmq.mountPage("Solar", function(scope) { ... }).
- Subscribe to broker-published solar updates with scope.subscribeToEvent("SolarData", handler).
- Request the initial snapshot in scope.onReady(...) with await scope.rpc.getSolarData().
- Use scope.rpc.* or scope.callRpc(...) for page-specific request/response calls.
- Do not publish raw SMQ messages from solar.js.
- On each SolarData event:
  - Update solarData
  - Re-render dashboard (Card 1 + bottom chart)
  - Bottom chart should "shift left" (append new value, drop oldest)
- Register chart resize cleanup and any timers/listeners with scope.onCleanup(...).
- Let cms-smq.js clean up page-owned SMQ subscriptions on HTMX fragment unload.

Server Data Model + Updates

- Update the preload script at custom/.preload:
  - Keep the authoritative simulated solarData state in broker memory.
  - Register a page-scoped RPC method named getSolarData with registerRpcMethod("getSolarData", function() ... end).
  - Use a ba.timer to update the broker-owned solarData state at random intervals between 1 and 10 seconds.
  - Broadcast each validated solarData update as the SolarData page event consumed by scope.subscribeToEvent("SolarData", handler).
  - Keep broker transport details inside custom/.preload; solar.js should only use the page-scope API.
  - Data should include at least:
    - energyToday
    - lifetimeMWh
    - powerKw
    - dailyValue (for shifting bar chart)

Security Headers

- Update CSP in cms.lua to allow:
  - https://api.open-meteo.com
  - https://ipapi.co
  - the selected ECharts CDN

Deliverables

- custom/.lua/www/solar.html
- custom/static/solar.js
- custom/static/solar.css
- custom/.lua/menu.json
- custom/.preload
- custom/.lua/cms.lua if CSP changes are needed

Verification
- Run mako -l::custom.
- Verify direct load, HTMX menu navigation, browser back/forward, and SMQ updates.
- Run node --check custom/static/solar.js.
- Confirm no jQuery and no extra SMQ.Client(...) calls were added.
```
