# HTML Forms and LSP for Beginners

## Overview

This example is the companion code for the [HTML Forms and LSP for Beginners](https://makoserver.net/articles/HTML-Forms-and-LSP-for-Beginners) tutorial. It focuses on the basics of handling form input with Lua Server Pages.

## Files

- `www/index.lsp` - Presents the example form, receives the submitted data, and shows how an LSP page can both render HTML and process form input.

## How to run

Start the example with the Mako Server:

```bash
cd html-form
mako -l::www
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

After the server starts, open `http://localhost:portno`, enter any value in the login field, and click the `Login` button.

## How it works

The example keeps everything in a single LSP page so it is easy to see the full request flow. The page emits the HTML form on `GET` and reads the submitted form fields when the browser posts data back to the same URL.

## Notes / Troubleshooting

- This example is intentionally simple and is meant to teach form handling, not production authentication design.
- In a real BAS application, you would typically use the built-in authentication and authorization APIs instead of creating a login flow manually. See the [authentication](../authentication) examples for that next step.
