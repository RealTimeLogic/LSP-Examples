# Light Dashboard Templates

Three ready-to-run dashboard UIs for embedded devices (routers, gateways, RTOS/firmware).

### What the Article Covers (High-Level)

**For a step-by-step walkthrough, diagrams, and acronyms, see the introductory article:**

- https://makoserver.net/articles/How-to-Build-an-Interactive-Dashboard-App

The article explains the design and behavior of this dashboard without requiring deep framework knowledge:

- **Two dashboard styles:** a default SSR flow and a lightweight HTMX-based CSR flow that uses partial updates but still falls back to SSR when JavaScript is off.
- **MVC-style structure:** `menu.json` defines pages, the CMS builds the response, and `template.lsp` wraps each page fragment.
- **Dynamic assembly:** pages are composed at runtime (template + fragment), which makes it easy to add or change pages.
- **Navigation + HTMX behavior:** HTMX requests return fragments while full requests return the complete layout.
- **WebSockets behavior:** SSR navigation closes sockets, while CSR can keep them alive if managed carefully. The CSR versions include code in WebSockets.js to explicitly close the SMQ connection on navigation; if you want persistent sockets, move SMQ loading into `template.lsp`.
- **Compression + authentication:** responses are compressed, and a TPM-backed user database is included for authentication.

## Versions at a glance

- **`www/`** - **SSR + Pure.css** (original server-side rendered version)
- **`htmx/`** - **CSR/HTMX + Pure.css** (HTML fragments assembled in the client)
- **`custom/`** - **CSR/HTMX + custom CSS** (two-level menu + modern design)

**Default for new work:** `custom/` (modern CSS and two-level navigation).

All three use the same CMS flow: `menu.json` defines pages, `cms.lua` routes requests, and `template.lsp` renders the shell around each page fragment.

The Pure.css–based versions are well suited for developers who are not CSS experts, as most of the layout and styling are handled by Pure.css with minimal customization required.

The custom version is the most flexible option. It is designed for creating a dashboard that closely matches your company’s visual identity, whether you prefer to work with a CSS designer or use AI to assist with theming and styling.

## Quick Start

Run the **SSR + Pure.css** version:

```
cd Light-Dashboard
mako -l::www
```

Run the **CSR/HTMX + Pure.css** version:

```
cd Light-Dashboard
mako -l::htmx
```

Run the **CSR/HTMX + custom CSS** version (recommended):

```
cd Light-Dashboard
mako -l::custom
```

Then open your browser at:

```
http://localhost:portno
```

## Authentication (Optional)

Authentication is **disabled by default**.

- **Enable:** Open **Users** in the left navigation and add at least one user. Once a user exists, authentication is enforced.
- **Add users:** You can add multiple users.
- **Remove a user:** Enter an existing username and leave the password blank.
- **Disable:** Remove all users; authentication is automatically disabled again.

## AI-Assisted Changes

This project is AI-friendly. It has been tested with [Codex](https://openai.com/codex/), but other AI engines should work as well.

- See [AGENTS.md](AGENTS.md) for the exact file map and update workflow.
- When using AI, say which version you want updated.
- For most changes, target **`custom/`** first, then port to `www/` and `htmx/` only if you want all three versions to stay in sync.
- AI example prompts are provided at the end of this document.

## Project Layout (Simplified)

```
Light-Dashboard/

  -www     -- SSR + Pure.css
    |   .preload -- Loads cms.lua when server starts
    |
    +---.lua
    |   |   cms.lua -- Mini Content Management System (CMS engine)
    |   |   menu.json -- Pages that should be in the dashboard menu
    |   |
    |   \---www -- All pages used by cms.lua (via template.lsp)
    |           template.lsp -- Common components, including menu generation
    |           form.html -- HTML Form example
    |           index.html -- Introduction
    |           WebSockets.html -- Persistent real-time connection howto
    |           404.html -- Triggered for pages not in menu.json
    |           login.html -- Triggered when not signed in
    |           logout.html -- Sign out page
    |           Users.html -- Add or remove users
    |
    \---static -- Pure.css files: See https://purecss.io/
            pure-min.css --  pure-min.css + grids-responsive-min.css
            styles.css -- For the dashboard
            ui.js -- Manages the Hamburger button logic. This button is visible on
             smaller devices or if you narrow the browser window. Details: https://purecss.io/

  -htmx/     -- CSR/HTMX + Pure.css
     -- (Similar to the www/ layout)

  -custom/   -- CSR/HTMX + custom CSS + 2-level menu
     -- (Similar to the www/ layout)

  - README.md
  - AGENTS.md
```

## How the CMS Routing Works (Short Version)

1. The CMS directory function in `cms.lua` checks whether the URL exists in `menu.json`.
2. It loads the corresponding page fragment from `.lua/www/`.
3. `template.lsp` renders the shared layout and injects the fragment.
4. The response is compressed before it is sent to the browser.

In the HTMX/CSR versions, HTMX requests return only the fragment; normal requests return the full layout.

## Add / Modify / Remove Pages

### Add a new page
1) Create a new fragment in `.lua/www/`, e.g. `Diagnostics.html`:

```
<div class="header">
  <h1>Diagnostics</h1>
</div>
<div class="content">
  ...
</div>
```

2) Add it to `.lua/menu.json`:

```
{ "name": "Diagnostics", "href": "Diagnostics.html" }
```

Or under a group in the **custom** version:

```
{
  "name": "System",
  "children": [
    { "name": "Diagnostics", "href": "Diagnostics.html" }
  ]
}
```

3) Apply the change in the version(s) you want to keep in sync:
- `custom/.lua/www/` (recommended default)
- `www/.lua/www/`
- `htmx/.lua/www/`

### Modify a page
- Edit the fragment in `.lua/www/`.
- If the menu label or location changes, update `.lua/menu.json`.
- Apply the change in the version(s) you want to keep in sync.

### Remove a page
- Delete the fragment file.
- Remove the matching entry from `.lua/menu.json`.

## Styling & UI

- `www/` and `htmx/` use **Pure.css**.
- `custom/` uses a **custom CSS design** with a two-level menu.
- Global styles live in `static/styles.css` and layout/menu behavior in `static/ui.js`.
- Keep page markup consistent by using `.header` and `.content` wrappers.

## Security Policies

Default security headers (including CSP) are in `cms.lua`. If you add new external scripts/styles, update CSP accordingly.

## Example AI Prompts

Below are example AI prompts you can use when working with an AI to modify the dashboards. For the complete AI workflow, file map, and rules for updates, refer to [AGENTS.md](AGENTS.md).

### UI style change for the custom theme.

You can use AI to change the theme of any of the three dashboard versions, but the custom version is usually the best starting point. It is also the preferred choice for professional web developers who want to fine-tune the styling manually, which is the recommended approach. In the following example, we provided a screenshot of an existing user interface found on the Internet from a Schneider Electric embedded web server, which serves as visual inspiration for the AI's theme update.

```
Update the custom/ version to match the look and feel of Schneider
Electric's (SE) website (se.com).

"I'm providing a screenshot of an embedded SE UI. Use it as a visual
reference to restyle the **custom** version. Make sure to analyze this
image before proceeding.

Requirements

- Match the screenshot's overall theme: colors, contrast, spacing, typography feel, and component styling.
- Keep the existing layout, two‑level menu, and HTMX behavior intact.
- Replace the top‑left "Company" brand text with the logo in custom/static/se-logo.svg.
- Keep the logo sized to fit the nav height and width.

Scope

- Modify **only** files under custom/.
- Update styles.css for palette, typography, nav, buttons, panels, and focus states.
- Update template.lsp only for the brand/logo slot (no routing or content changes).
- Update any other file that may need UI changes.

Notes

- Keep CSS readable and well‑commented.
- Do not change page content or menu structure.
- If any external assets are needed, call them out explicitly and update CSP (but prefer local assets).
```
