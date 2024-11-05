# Light Dashboard Template

This example shows how to implement a dashboard (device management
app) suitable for constrained devices such as RTOS/firmware type
devices.

![Light Dashboard Template](https://makoserver.net/blogmedia/dashboard/Light-Dashboard.gif)

## Tutorial and hands-on microcontroller example:
The server-side logic and web rendering are explained in the [dashboard article](https://makoserver.net/articles/How-to-Build-an-Interactive-Dashboard-App). For a hands-on microcontroller example of how to use this dashboard, see the tutorial, [Designing Your First Professional Embedded Web Interface](https://realtimelogic.com/articles/Designing-Your-First-Professional-Embedded-Web-Interface).

## How to run using the Mako Server:
Run the dashboard example, using the [Mako Server](https://makoserver.net/), as follows:

```
cd Light-Dashboard
mako -l::www
```
For detailed instructions on starting the Mako Server, check out our [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and review the server's [command line options](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp) in our documentation.

After starting the Mako Server, use a browser and navigate to
http://localhost:portno, where portno is the HTTP port number used by
the Mako Server (printed in the console). Login with the username
admin and password qwerty.


## 'LSP-Examples/Light-Dashboard' Files:

```
---www
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
            ui.js -- See https://purecss.io/
```


## The server side code works as follows:

1. A [directory function](https://realtimelogic.com/ba/doc/?url=GettingStarted.html#directory) (in cms.lua) triggers when the user navigates to the server
2. The directory function checks if the requested URL is in the file menu.json
3. The directory function then loads and parses the LSP page to be executed and saves the "LSP page function" as variable 'lspPage' in the [request/response environment](https://realtimelogic.com/ba/doc/?url=lua.html#CMDE)
4. The directory function calls the "pre parsed" template.lsp function
5. The code in template.lsp renders the menu and static HTML components part of the 'theme'
6. Template.lsp calls the "LSP page function" stored as variable 'lspPage'
7. The "LSP page function" renders the page specific content
8. The dynamically generated HTML is sent to the client (the browser)


## Authentication

This example includes a [soft TPM-protected](https://realtimelogic.com/ba/doc/en/lua/auxlua.html#TPM) user database, along with a web interface for adding and removing users. The authentication logic is based on the example provided with [function ba.tpm.jsonuser()](https://realtimelogic.com/ba/doc/en/lua/auxlua.html#ba_tpm_jsonuser).

Here's how the authentication works: if no users are found in the database, authentication is disabled. Once a user is added, authentication is automatically enabled. Conversely, removing the last user disables authentication again.

The Users.html page provides a simple interface for managing the user database, allowing the addition and removal of users. For simplicity, the authentication code focuses purely on user authentication, without any authorization mechanisms.

## Security Policies

The following default security policies are set to enhance security by controlling content sources and protecting against MIME-type sniffing:

- Content-Security-Policy: Limits resources (scripts, styles) to load only from trusted sources. By default, it restricts all resources to 'self', with an exception for scripts and styles from cdn.jsdelivr.net. You may need to adjust this policy to include additional trusted domains based on your application's requirements.
- X-Content-Type-Options: Set to "nosniff" to prevent browsers from interpreting files as a different MIME type than declared. This helps prevent certain attacks that rely on MIME-type misinterpretation.

**Note:** These policies are examples and may require customization to meet the specific needs of your deployment environment and any third-party services you integrate. See www/.lua/cms.lua and 'securityPolicies' for details.


## Notes:

We use camel case naming convention in the example code. The Lua table
type implements associative arrays. An associative array is an array
that can be indexed not only with numbers but also with keys such as
strings. We use the naming convention tableT when the table expects a
key based lookup and the naming convention tableL when the table is a
list (array).
