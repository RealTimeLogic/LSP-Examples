# Light Dashboard Templates

## Overview

This directory contains three ready-to-run dashboard UIs for embedded devices such as routers, gateways, and firmware-backed products.

The introductory article for the design is:

- https://makoserver.net/articles/How-to-Build-an-Interactive-Dashboard-App

All three variants use the same CMS-style flow: `menu.json` defines the pages, `cms.lua` routes requests, and `template.lsp` renders the shared shell around each page fragment.

Available variants:

- `www/` - SSR + Pure.css
- `htmx/` - CSR/HTMX + Pure.css
- `custom/` - CSR/HTMX + custom CSS, two-level navigation, and the default target for new work

Authentication is optional and disabled by default. In the default `custom/` variant, user management is backed by a TPM-enabled encrypted user database when TPM support is available.

## Files

- `custom/.lua/cms.lua`, `htmx/.lua/cms.lua`, `www/.lua/cms.lua` - Mini CMS/router for each variant.
- `custom/.lua/menu.json`, `htmx/.lua/menu.json`, `www/.lua/menu.json` - Menu and routing source of truth.
- `custom/.lua/www/template.lsp`, `htmx/.lua/www/template.lsp`, `www/.lua/www/template.lsp` - Shared layout shells.
- `custom/.lua/www/*.html`, `htmx/.lua/www/*.html`, `www/.lua/www/*.html` - Page fragments rendered inside the layout.
- `custom/static/`, `htmx/static/`, `www/static/` - Variant-specific CSS and JavaScript assets.
- `AGENTS.md` - Detailed file map and update guidance, with `custom/` as the default variant for new work.

## How to run

Run the SSR + Pure.css variant:

```bash
cd Light-Dashboard
mako -l::www
```

Run the CSR/HTMX + Pure.css variant:

```bash
cd Light-Dashboard
mako -l::htmx
```

Run the CSR/HTMX + custom CSS variant:

```bash
cd Light-Dashboard
mako -l::custom
```

Then open `http://localhost:portno`.

Authentication behavior:

- Add at least one user on the `Users` page to enable authentication.
- Remove all users to disable authentication again.

## How it works

Each variant inserts a CMS directory function alongside the resource reader so that static assets still take precedence. The CMS callback:

1. resolves directory requests to `index.html`
2. checks whether the requested page exists in `menu.json`
3. loads the page fragment from `.lua/www/`
4. returns either the fragment alone for HTMX requests or the full `template.lsp` shell for normal requests
5. applies security headers and compressed responses

The `custom/` variant adds nested menu support through `children` arrays in `menu.json` and renders a two-level menu in the template. If TPM support is available, the CMS also enables a form authenticator dynamically when at least one user exists in the encrypted user database.

### Why the variants differ

The introductory article explains the tradeoffs in more detail, but the high-level split is:

- **SSR + Pure.css** for a classic server-rendered experience
- **CSR/HTMX + Pure.css** for fragment-based updates with a familiar CSS framework
- **CSR/HTMX + custom CSS** for the most flexible visual design and a two-level menu

The article also calls out a few practical details that matter in real products:

- HTMX requests return fragments, while full requests return the complete layout.
- Pages are composed dynamically at runtime from `template.lsp` plus the requested fragment.
- SSR navigation closes real-time connections, while the CSR variants can preserve them if you move socket-loading code into the shared shell instead of page-specific code.
- Responses are compressed, and authentication can be layered in without changing each individual page.

### Project layout

```text
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
    |           RoundSlider.html -- Persistent real-time connection howto
    |           404.html -- Triggered for pages not in menu.json
    |           login.html -- Triggered when not signed in
    |           logout.html -- Sign out page
    |           Users.html -- Add or remove users
    |
    \---static -- Pure.css files
            pure-min.css -- pure-min.css + grids-responsive-min.css
            styles.css -- Dashboard styles
            ui.js -- Hamburger/menu logic

  -htmx/     -- CSR/HTMX + Pure.css
     -- Similar to the www/ layout

  -custom/   -- CSR/HTMX + custom CSS + 2-level menu
     -- Similar to the www/ layout

  - README.md
  - AGENTS.md
```

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

## Notes / Troubleshooting

- For AI-assisted updates, see [AGENTS.md](AGENTS.md) and target `custom/` first unless you specifically want parity across all three variants.
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

This project is intentionally AI-friendly. It has been tested with Codex, but the same workflow can be used with other tools as long as you keep the variant boundaries clear:

- say which variant you want changed
- target `custom/` first for new work
- port the same change to `www/` and `htmx/` only if you need parity

### Example AI prompts

Below are the original example prompts that ship with the project. They are intentionally detailed because real dashboard changes often span layout, CSS, runtime behavior, and security headers at the same time.

#### UI style change for the custom theme

You can use AI to change the theme of any of the three dashboard variants, but the custom variant is usually the best starting point. It is also the preferred choice for professional web developers who want to fine-tune the styling manually. In the original example, a screenshot from a Schneider Electric embedded web server was used as the visual reference.

```text
Update the custom variant to match the look and feel of Schneider
Electric's (SE) website (se.com).

"I'm providing a screenshot of an embedded SE UI. Use it as a visual
reference to restyle the custom variant. Make sure to analyze this
image before proceeding.

Requirements

- Match the screenshot's overall theme: colors, contrast, spacing, typography feel, and component styling.
- Keep the existing layout, two-level menu, and HTMX behavior intact.
- Replace the top-left "Company" brand text with the logo in custom/static/se-logo.svg.
- Keep the logo sized to fit the nav height and width.

Scope

- Modify only files under custom/.
- Update styles.css for palette, typography, nav, buttons, panels, and focus states.
- Update template.lsp only for the brand/logo slot (no routing or content changes).
- Update any other file that may need UI changes.

Notes

- Keep CSS readable and well-commented.
- Do not change page content or menu structure.
- If any external assets are needed, call them out explicitly and update CSP (but prefer local assets).
```

Reference image:

![Schneider Electric UI](https://makoserver.net/blogmedia/dashboard/se.jpg)

#### Preparing the dashboard for persistent real-time data

The two HTMX dashboard variants behave similarly to a SPA because the page shell stays loaded while fragments are swapped. That makes them a good fit for persistent SMQ or WebSocket connections, but the connection code needs to live in the shell, not in the individual page fragment.

The original prompt used for that change was:

```text
I want the SMQ connection to remain persistent across HTMX-loaded page fragments.

Requirements
- Split the current RoundSlider.js into two files:
  - WebSockets.js: responsible for loading, connecting, and maintaining the SMQ connection
  - RoundSlider.js: uses the global smq object created by WebSockets.js and subscribes to the same topic
- Load WebSockets.js in template.lsp so it is always present, and the SMQ connection persists across page swaps
  - The JavaScript SMQ client "/rtl/smq.js" must also be loaded by template.lsp
- RoundSlider.js should:
  - Subscribe on load, full page load and HTMX swap (fragment load)
  - Unsubscribe when the RoundSlider fragment is unloaded by using HTMX lifecycle event htmx:beforeSwap
  - Request the initial slider state only once per full-page/fragment load, and only after subscribe is complete
- Do not break SSR or normal full-page loads

Behavior details
- The SMQ connection should stay alive across HTMX navigation
- The slider fragment should not leave stale subscriptions behind
- The slider position stored by the broker/server must not be overwritten on client initialization

jQuery constraint
- Only RoundSlider.js may use jQuery
- WebSockets.js must be native JS only
- Any non-plugin logic that can be native should stay in WebSockets.js

Scope
- Modify only custom/ files
- Create WebSockets.js and update RoundSlider.js
- Update template.lsp to include WebSockets.js
- Update RoundSlider.html to include only RoundSlider.js
- Dashboard variant to use: custom/
```

#### Solar dashboard prompt

The repo also includes a more advanced prompt for creating a full solar dashboard page, including charting, live data, server-side publishing, and CSP updates. The original documentation keeps that prompt because it shows how a single feature request can affect:

- menu registration
- page fragments
- CSS and JavaScript
- real-time subscriptions
- server-side simulation data
- security headers

Reference image:

![Solar Dashboard](https://makoserver.net/blogmedia/dashboard/solar.jpg)

The full original prompt is preserved here for reference:

```text
Task: Create Solar Dashboard Page

Create a new solar dashboard page using vanilla HTML/CSS/JS, inspired
by the attached screenshot (dark industrial UI, 2 top cards, large
bottom bar chart). Use a warm gold accent for primary numbers and
bars, light gray for labels, and charcoal/black with subtle gradients
for everything else.

Target variant: custom/

- Page fragment: solar.html
- JS: solar.js
- CSS: solar.css

Menu

- Add a new top-level menu item at the end of menu.json: name: Solar, link solar.html

Libraries

- Use Apache ECharts from a CDN.
- No frameworks/build tools.
- Do not use external icon libraries; use inline SVG or basic shapes.
- The file solar.js must be native JS only.

Layout / Components

1. Card 1: Energy Today
   - Big number: 93.07 kWh (example)
   - Smaller line: Lifetime: 143.69 MWh
   - Circular ECharts gauge showing 18.7 kW (example)
   - Include a thin "timeline" indicator (HTML/CSS is fine)
2. Card 2: Weather
   - Big number: 52°
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

- Reuse the persistent window.smq created by WebSockets.js (do not create a new connection).
- Subscribe to topic "/solarData" with logic similar to RoundSlider.
- On SMQ message:
  - Update solarData
  - Re-render dashboard (Card 1 + bottom chart)
  - Bottom chart should "shift left" (append new value, drop oldest)
- Unsubscribe on HTMX fragment unload (use htmx:beforeSwap targeting #main).

Server Data Model + Updates

- Update the preload script at custom/.preload:
  - Publish simulated JSON data to topic "/solarData" using the SMQ broker object smq
  - Use a ba.timer to publish at random intervals between 1-10 seconds.
  - Data should include at least:
    - energyToday
    - lifetimeMWh
    - powerKw
    - dailyValue (for shifting bar chart)

Security Headers

- Update CSP in cms.lua to allow:
  - https://api.open-meteo.com
  - https://ipapi.co
  - Ensure ECharts CDN remains allowed

Deliverables

- solar.html
- solar.js
- solar.css
- Modify menu.json, custom/.preload, and cms.lua as needed
```
