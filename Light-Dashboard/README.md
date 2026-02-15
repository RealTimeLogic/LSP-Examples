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
- **WebSockets behavior:** SSR navigation closes sockets, while CSR can keep them alive if managed carefully. The CSR variants include code in RoundSlider.js to explicitly close the SMQ connection on navigation; if you want persistent sockets, move SMQ loading into `template.lsp`.
- **Compression + authentication:** responses are compressed, and a TPM-backed user database is included for authentication.

## Variants at a glance

- **`www/`** - **SSR + Pure.css** (original server-side rendered version)
- **`htmx/`** - **CSR/HTMX + Pure.css** (HTML fragments assembled in the client)
- **`custom/`** - **CSR/HTMX + custom CSS** (two-level menu + modern design)

**Default for new work:** `custom/` (modern CSS and two-level navigation).

All three use the same CMS flow: `menu.json` defines pages, `cms.lua` routes requests, and `template.lsp` renders the shell around each page fragment.

The Pure.css–based variants are well suited for developers who are not CSS experts, as most of the layout and styling are handled by Pure.css with minimal customization required.

The custom variant is the most flexible option. It is designed for creating a dashboard that closely matches your company’s visual identity, whether you prefer to work with a CSS designer or use AI to assist with theming and styling.

## Quick Start

Run the **SSR + Pure.css** variant:

```
cd Light-Dashboard
mako -l::www
```

Run the **CSR/HTMX + Pure.css** variant:

```
cd Light-Dashboard
mako -l::htmx
```

Run the **CSR/HTMX + custom CSS** variant (recommended):

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
- When using AI, say which variant you want updated.
- For most changes, target **`custom/`** first, then port to `www/` and `htmx/` only if you want all three variants to stay in sync.
- [AI example prompts are provided at the end of this document](#example-ai-prompts).

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
    |           RoundSlider.html -- Persistent real-time connection howto
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

In the HTMX/CSR variants, HTMX requests return only the fragment; normal requests return the full layout.

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

Or under a group in the **custom** variant:

```
{
  "name": "System",
  "children": [
    { "name": "Diagnostics", "href": "Diagnostics.html" }
  ]
}
```

3) Apply the change in the variant(s) you want to keep in sync:
- `custom/.lua/www/` (recommended default)
- `www/.lua/www/`
- `htmx/.lua/www/`

### Modify a page
- Edit the fragment in `.lua/www/`.
- If the menu label or location changes, update `.lua/menu.json`.
- Apply the change in the variant(s) you want to keep in sync.

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

You can use AI to change the theme of any of the three dashboard variants, but the custom variant is usually the best starting point. It is also the preferred choice for professional web developers who want to fine-tune the styling manually, which is the recommended approach. In the following example, we provided a screenshot of an existing user interface found on the Internet from a Schneider Electric embedded web server, which serves as visual inspiration for the AI's theme update. As part of the prompt below, **copy and paste a screenshot of an existing user interface**.

```
Update the custom variant to match the look and feel of Schneider
Electric's (SE) website (se.com).

"I'm providing a screenshot of an embedded SE UI. Use it as a visual
reference to restyle the **custom** variant. Make sure to analyze this
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

#### The Generated UI:

![Schneider Electric UI](https://makoserver.net/blogmedia/dashboard/se.jpg)


### Preparing the Dashboard for Persistent Real-Time Data

The following prompts are designed for the two HTMX-based dashboard variants and are best suited for the custom variant.

When designing dashboards for embedded systems, a persistent real-time connection to the server is preferred because it allows the server to push live data to the client. This works naturally in Single Page Applications (SPAs), where the application shell typically remains loaded during use. In a traditional server-side rendered design, the connection must be re-established each time a new page is loaded.

The two HTMX dashboard variants behave similarly to a SPA because the page frame is not reloaded when navigating between pages. To take advantage of this, the SMQ WebSocket connection should not live inside individual page code. Instead, it should be part of the page frame so the connection remains persistent and can be shared by page fragments that are loaded on demand.

The following prompt implements this design and prepares the dashboard for the next prompt, where a [Solar Dashboard Plugin](#solar-dashboard) is added.

```
I want the SMQ connection to remain persistent across HTMX‑loaded page fragments.

Requirements
- Split the current RoundSlider.js into two files:
  - WebSockets.js: responsible for loading, connecting, and maintaining the SMQ connection
  - RoundSlider.js: uses the global smq object created by WebSockets.js and subscribes to the same topic
- Load WebSockets.js in template.lsp so it is always present, and the SMQ connection persists across page swaps
  - The JavaScript SMQ client "/rtl/smq.js" must also be loaded by template.lsp
- RoundSlider.js should:
  - Subscribe on load, full page load and HTMX swap (fragment load)
  - Unsubscribe when the RoundSlider fragment is unloaded by using HTMX lifecycle event htmx:beforeSwap
  - Request the initial slider state **only once per full-page/fragment load**, and **only after subscribe is complete** (so the broker response isn't missed)
- Do not break SSR or normal full-page loads

Behavior details
- The SMQ connection should stay alive across HTMX navigation
- The slider fragment should not leave stale subscriptions behind
- The slider position stored by the broker/server must NOT be overwritten on client initialization:
  the client slider should publish only on actual user interaction

jQuery constraint
- Only RoundSlider.js may use jQuery (needed for the RoundSlider plugin)
- WebSockets.js must be native JS only (no jQuery)
- Any non‑plugin logic that can be native should stay in WebSockets.js

Scope
- Modify only custom/ files
- Create WebSockets.js and update RoundSlider.js
- Update template.lsp to include WebSockets.js
- Update RoundSlider.html to include only RoundSlider.js
- Dashboard variant to use: custom/
```

### Solar Dashboard

The following prompt enables the AI to design a fully functional solar dashboard. The dashboard is implemented as a new page and integrated into the existing dashboard framework.

The following image shows the AI generated Solar Dashboard:

![Solar Dashboard](https://makoserver.net/blogmedia/dashboard/solar.jpg)

The following prompt is detailed because it reflects real production work and real design decisions. Even when using AI, the developer must understand the full design process and how a feature spans multiple layers. A single change affects UI layout, charting, data models, live updates, security headers, and server-side publishing. If these relationships are not specified explicitly, an AI or a human, for that matter, will fill in the gaps with assumptions that often break the implementation.

**Note:** You must execute the above prompt before this one. You can use a screenshot of a solar panel as part of this prompt.

```
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

- Add a new top‑level menu item at the end of menu.json: name: Solar, link solar.html

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
   - The temperature must be updated using real-time data from Open‑Meteo
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

- Use the Open‑Meteo endpoint to retrieve the current temperature, weather code, and time/date.
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
