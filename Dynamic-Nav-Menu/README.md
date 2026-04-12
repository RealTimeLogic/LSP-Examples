# Dynamic Navigation Menu

## Overview

This example accompanies the [Dynamic Navigation Menu](https://makoserver.net/articles/Dynamic-Navigation-Menu) tutorial. It demonstrates a simple multi-page application with a shared navigation header, a custom 404 flow, and form-based authentication that is initialized in the application's startup script.

## Files

- `www/.preload` - Installs the form authenticator, loads the JSON user database, and registers a custom 404 handler.
- `www/.header.lsp` - Renders the shared navigation menu and marks the active page.
- `www/.login-form.lsp` - Form-based login page used by the authenticator.
- `www/.404.lsp` - Custom page used when a route is not found.
- `www/index.lsp`, `www/network.lsp`, `www/security.lsp`, `www/users.lsp`, `www/admin.lsp` - Main content pages shown through the shared layout.
- `www/public/` - Static CSS, JavaScript, and image resources that stay accessible without authentication.

## How to run

Start the example with the Mako Server:

```bash
cd Dynamic-Nav-Menu
mako -l::www
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

After the server starts, open `http://localhost:portno`, where `portno` is the HTTP port shown in the Mako console. Log in with:

- Username: `admin`
- Password: `password`

After logging in, click the `ADMIN` tab to see the built-in file list and page descriptions.

## How it works

The application's `www/.preload` script sets up two main pieces of behavior. First, it creates a sibling directory handler that forwards unresolved requests to `/.404.lsp`. Second, it creates a JSON-backed user database, configures a form authenticator with a custom login-response callback, and applies that authenticator to the application's `dir`.

Each protected page includes the shared header logic from `.header.lsp`, which generates the menu and highlights the active tab. Static resources under `www/public/` stay public so the login page can load its styles and scripts before the user is authenticated.

## Notes / Troubleshooting

- This example uses hashed passwords in the user database, so the realm configured in `.preload` must match the stored HA1 values.
- If you change the realm or the stored hashes, update both sides together.

