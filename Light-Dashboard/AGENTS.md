# AGENTS.md - Light Dashboard (Default: custom/)

Purpose
- This repo ships three versions of the dashboard. The **default target for new work is `custom/`**, which uses CSR/HTMX + custom CSS + a two-level menu.
- The `www/` (SSR + Pure.css) and `htmx/` (CSR/HTMX + Pure.css) versions are maintained for reference or parity. Update them only if you need all versions in sync.

AI usage
- This project has been tested with **Codex**, but other AI engines should work.
- Always point AI to this file (AGENTS.md) and specify the target version.

Key files and what they do (custom/ default)
- custom/.lua/www/template.lsp: Layout shell (left nav + main pane). Calls lspPage() to inject page content. Updates here affect every page.
- custom/.lua/menu.json: Menu and routing source of truth. Items here define navigable pages (supports nested groups via "children").
- custom/.lua/cms.lua: Router and page loader. Reads menu.json, builds menu tables (including nested items), loads pages, and applies security headers.
- custom/.lua/www/*.html: Individual page fragments (can contain LSP). Use .header and .content wrappers for consistent styling.
- custom/static/styles.css: Global styling for layout, nav, and forms.
- custom/static/ui.js: Handles hamburger menu toggle and nav group expand/collapse.
- custom/static/*.js|*.css: Page-specific assets (e.g., WebSockets.css/WebSockets.js).

Equivalent paths for the other versions
- Replace `custom/` with `www/` (SSR + Pure.css) or `htmx/` (CSR/HTMX + Pure.css).

How routing works (quick mental model)
- The directory callback (cms.lua) checks menu.json for the requested href.
- If found, cms.lua loads the corresponding page from .lua/www/<href>.
- template.lsp renders the chrome and injects the page fragment.
- If a page is not in menu.json, it returns 404 unless explicitly allowed.

Add a new page (standard flow)
1) Create the page file
   - Add a new file in custom/.lua/www, e.g. Diagnostics.html.
   - Use the common layout:
     - <div class="header"><h1>Title</h1></div>
     - <div class="content">...</div>

2) Register the page in the menu
   - Add an item in custom/.lua/menu.json.
   - Top-level item example:
     { "name": "Diagnostics", "href": "Diagnostics.html" }

   - Nested group example (custom only):
     {
       "name": "System",
       "children": [
         { "name": "Diagnostics", "href": "Diagnostics.html" }
       ]
     }

   - If a page should only appear when authenticated, add:
     { "auth": true }

3) Add assets if needed
   - Place local CSS/JS in custom/static and reference them from the page.
   - If you add external CDN resources, update the CSP in custom/.lua/cms.lua.

4) Verify
   - Start the server:
     mako -l::custom
   - Navigate to the page and confirm the menu highlight and layout.

Modify an existing page
- Update the page file in custom/.lua/www.
- If the nav label or location changes, update the matching entry in custom/.lua/menu.json.
- If you need parity, apply the same change in www/ and htmx/.

Remove a page
1) Remove the file from custom/.lua/www.
2) Remove the item from custom/.lua/menu.json.
3) Clean up any related assets in custom/static.

Notes about the two-level menu (custom)
- custom/.lua/menu.json supports nested groups via "children" arrays.
- The menu renderer in template.lsp expands the active group; other groups are collapsed by default.
- To change expand/collapse behavior, adjust custom/static/ui.js and nav styles in custom/static/styles.css.

Style guidelines for new pages (custom)
- Use .header and .content wrappers for a consistent look.
- Use the form classes when building forms:
  - .form, .panel, .form-grid, .form-field, .form-actions
- If you need a narrower form, add the .form-narrow class.

Security headers
- The default Content-Security-Policy is defined in custom/.lua/cms.lua.
- Update it whenever you add external scripts or styles.
