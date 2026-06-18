# AGENTS.md - Light Dashboard (Default: custom/)

Purpose
- This repo ships three dashboard variants. The default target for new work is `custom/`, which uses CSR/HTMX, custom CSS, a two-level menu, and CMS-level SMQ support.
- The `www/` (SSR + Pure.css) and `htmx/` (CSR/HTMX + Pure.css) variants are maintained for reference or parity. Update them only when the user asks for all variants to stay in sync.

AI usage
- This project has been tested with Codex, but other AI engines should work.
- Always point AI to this file (`AGENTS.md`) and specify the target variant.
- For `custom/` development, also point AI to [doc/custom-skill.md](doc/custom-skill.md). It is the agent-facing development skill for layout/color changes, page add/remove flows, HTMX behavior, and SMQ page scopes.
- For detailed custom CMS design notes, see [doc/custom-design.md](doc/custom-design.md).
- For native SMQ client behavior, treat the official SMQ JavaScript docs as source of truth: https://realtimelogic.com/ba/doc/en/JavaScript/SMQ.html
- For native SMQ broker behavior, treat the official SMQ Lua docs as source of truth: https://realtimelogic.com/ba/doc/en/lua/SMQ.html
- In the `custom/` variant, page scripts do not use the native SMQ client API directly. They use the CMS page-scope API in `custom/static/cms-smq.js`; consult [doc/custom-skill.md](doc/custom-skill.md) and [doc/custom-design.md#page-scopes](doc/custom-design.md#page-scopes) before writing page-level SMQ code.
- For the Barracuda App Server Lua/LSP API, treat the official Lua API documentation as source of truth: https://realtimelogic.com/ba/doc/en/lua/lua.html
- For the Barracuda App Server Auxiliary Lua APIs (HTTP client, sockets, ByteArray, UBJSON, etc.), treat the official AuxLua API documentation as source of truth: https://realtimelogic.com/ba/doc/en/lua/auxlua.html
- Server-side Lua SMQ publish signatures: broadcast is `smq:publish(data, "topic")`, direct is `smq:publish(data, ptid, "topic")`.
- Do not add query-string cache busters such as `?v=custom` to reusable examples/templates.

Key files and what they do (custom/ default)
- `custom/.lua/www/template.lsp`: Layout shell (left nav + main pane). Calls `lspPage()` to inject page content. Loads HTMX, `/rtl/smq.js`, `/static/cms-smq.js`, and `/static/ui.js`. Updates here affect every page.
- `custom/.lua/menu.json`: Menu and routing source of truth. Items here define navigable pages and support nested groups via `children`.
- `custom/.lua/cms.lua`: Router and page loader. Reads `menu.json`, builds menu tables, loads pages, applies security headers, and decides whether to return a full shell or HTMX fragment.
- `custom/.lua/www/*.html`: Individual page fragments (can contain LSP). Use `.header` and `.content` wrappers for consistent styling.
- `custom/static/styles.css`: Global styling for layout, colors, nav, forms, and reusable page primitives.
- `custom/static/ui.js`: Native JavaScript for hamburger menu toggle, nav group expand/collapse, active-link sync, document title updates, and browser history restoration behavior.
- `custom/static/cms-smq.js`: Shared browser-side SMQ connection and page-scope lifecycle manager. Page fragments use this instead of creating their own SMQ clients.
- `custom/.preload`: Starts the CMS SMQ broker and exposes broker handlers used by custom pages.
- `custom/SMQ/index.lsp`: SMQ connection endpoint for the custom CMS.
- `custom/static/*.js|*.css`: Page-specific assets, such as `RoundSlider.css` and `RoundSlider.js`.
- `doc/custom-design.md`: Detailed explanation of the custom CMS engine and SMQ scaffolding.
- `doc/custom-skill.md`: Agent skill for developing the custom variant.

Equivalent paths for the other variants
- Replace `custom/` with `www/` (SSR + Pure.css) or `htmx/` (CSR/HTMX + Pure.css).
- Do this only when parity is required. The `custom/` variant is the primary target for new work.

How routing works (quick mental model)
- The directory callback in `cms.lua` checks `menu.json` for the requested href.
- If found, `cms.lua` loads the matching page from `custom/.lua/www/<href>`.
- Normal browser requests return `template.lsp`, which renders the chrome and injects the page fragment.
- HTMX requests return only the page fragment.
- HTMX history-restore requests return the full shell so browser back/forward works after a cache miss.
- If a page is not in `menu.json`, it returns 404 unless explicitly allowed.

Add a new page (standard flow)
1. Create the page file.
   - Add a new file in `custom/.lua/www`, for example `Diagnostics.html`.
   - Use the common layout:
     ```html
     <div class="header"><h1>Diagnostics</h1></div>
     <div class="content">...</div>
     ```

2. Register the page in the menu.
   - Add an item in `custom/.lua/menu.json`.
   - Top-level item example:
     ```json
     { "name": "Diagnostics", "href": "Diagnostics.html" }
     ```
   - Nested group example:
     ```json
     {
       "name": "System",
       "children": [
         { "name": "Diagnostics", "href": "Diagnostics.html" }
       ]
     }
     ```
   - If a page should only appear when authenticated, add:
     ```json
     { "auth": true }
     ```

3. Add assets if needed.
   - Place local CSS/JS in `custom/static` and reference them from the page.
   - Prefer local assets and native JavaScript.
   - If you add external CDN resources, update the CSP in `custom/.lua/cms.lua`.

4. Verify.
   - Start the server:
     ```bash
     mako -l::custom
     ```
   - Navigate to the page and confirm the menu highlight and layout.
   - Use browser back/forward to confirm HTMX history behavior.

Modify an existing page
- Update the page file in `custom/.lua/www`.
- If the nav label or location changes, update the matching entry in `custom/.lua/menu.json`.
- If page-specific assets change, keep them under `custom/static`.
- If you need parity, apply the same change in `www/` and `htmx/`.

Remove a page
1. Remove the page entry from `custom/.lua/menu.json`.
2. Remove the page file from `custom/.lua/www`.
3. Clean up related assets in `custom/static` when no remaining page uses them.
4. Verify that direct navigation to the removed page returns 404.

Layout and color customization
- Change global layout and visual design primarily in `custom/static/styles.css`.
- Start with `:root` variables before hardcoding new colors.
- Important shell selectors are `#layout`, `#menu.side-nav`, and `#main.main-pane`.
- Common page primitives are `.header`, `.content`, `.panel`, `.form`, `.form-grid`, `.form-field`, `.form-actions`, and `.btn`.
- Edit `custom/.lua/www/template.lsp` only for structural shell changes.
- Keep `id="main"` and `hx-history-elt` on the main content pane.
- Keep nav links using `hx-get`, `hx-push-url="true"`, and `hx-target="#main"`.
- Keep `/rtl/smq.js`, `/static/cms-smq.js`, and `/static/ui.js` loaded by the shell.

Notes about the two-level menu (custom)
- `custom/.lua/menu.json` supports nested groups via `children` arrays.
- The menu renderer in `template.lsp` expands the active group; other groups are collapsed by default.
- To change expand/collapse behavior, adjust `custom/static/ui.js` and nav styles in `custom/static/styles.css`.

Style guidelines for new pages (custom)
- Use `.header` and `.content` wrappers for a consistent look.
- Use form classes when building forms: `.form`, `.panel`, `.form-grid`, `.form-field`, `.form-actions`.
- If you need a narrower form, add the `.form-narrow` class.

SMQ in custom pages
- The official SMQ docs define the underlying native API. The custom CMS intentionally wraps that API for page fragments so page code has a stable lifecycle under HTMX.
- The custom CMS creates one shared SMQ connection from `custom/static/cms-smq.js` on every full page load.
- HTMX page changes swap only `#main`, so the SMQ connection stays open while fragments are loaded and unloaded.
- Page fragments must not call `SMQ.Client(...)` directly. `SMQ.Client(...)` should normally appear only in `custom/static/cms-smq.js`.
- Pages that use SMQ should create a page scope with `window.cmsSmq.mountPage("PageName", function(scope) { ... })`.
- Use `scope.subscribeToEvent(topic, handler)` for one-to-many published topics.
- Use `scope.subscribeToDirectMessage(subtopic, handler)` for direct messages addressed to this browser client.
- Use `scope.sendToBroker(messageName, payload)` for broker-mediated requests to the server-side `"self"` topic.
- Use `scope.sendToPeer(peerTid, messageName, payload)` only when the page intentionally sends direct one-to-one messages to a known destination TID.
- Use `scope.publishEvent(eventName, payload)` for one-to-many browser-originated events.
- Use `scope.rpc.methodName(...)` or `scope.callRpc("methodName", ...args)` for page-specific request/response flows that need Promise-style RPC or multiple concurrent requests. The CMS maps these to `"$RpcReq"` / `"$RpcResp"` with correlation IDs.
- Use `scope.onReady(...)` for initial SMQ requests that depend on subscriptions being ready.
- Use `scope.onCleanup(...)` for DOM timers/listeners/resources that must be released when HTMX unloads the fragment. Do not disconnect SMQ in page cleanup.
- See [doc/custom-skill.md](doc/custom-skill.md) and [doc/custom-design.md#page-scopes](doc/custom-design.md#page-scopes) for the full page-scope contract.

Security headers
- The default Content-Security-Policy is defined in `custom/.lua/cms.lua`.
- Update it whenever you add external scripts or styles.

Verification checklist
- Run `mako -l::custom`.
- Check direct full page loads, HTMX navigation, and browser back/forward.
- If SMQ is involved, verify full reload plus HTMX navigation away from and back to the page.
- Run `node --check` on changed JavaScript files.
