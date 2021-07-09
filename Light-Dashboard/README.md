# Light Dashboard Template

This example shows how to implement a dashboard (device management
app) suitable for constrained devices such as RTOS/firmware type
devices.

![Light Dashboard Template](https://makoserver.net/blogmedia/dashboard/Light-Dashboard.gif)

We provide two dashboard templates, this light version and a more
advanced dashboard based on the
[Bootstrap powered AdminLTE dashboard](../Dashboard). We recommend
testing both dashboards on your host computer to get a solid
understanding on how to create your own dashboard -- i.e. which of the dashboards you should base your design on or what server side code
you should use for your own custom HTML/CSS.

The server side logic and rendering is similar for both dashboards,
but the more advanced AdminLTE dashboard's server side code
must manage the breadcrumb generation and proper menu expansion of sub
menus. See the
[AdminLTE dashboard article on the Mako Server site](https://makoserver.net/articles/How-to-Build-an-Interactive-Dashboard-App)
for an introduction to how both dashboards dynamically render
HTML on the server side.

Run the dashboard example, using the Mako Server, as follows:

```
cd Light-Dashboard
mako -l::www
```

See the [Mako Server command line video tutorial](https://youtu.be/vwQ52ZC5RRg) for more information on how to start the Mako Server.

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
    |           no-access.lsp -- Triggered by authenticator/authorizer when user has no access
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


## Authentication and Authorization

An authenticator is installed for all pages. You have full access to
all resources if you log in as the user 'admin' and password
'qwerty'. See the hard coded values in source/.lua/cms.lua for
additional users and the constraints set for the users. We use hard
coded values for simplicity. A real application would store the users
and the optional constraints as JSON data in two files.

See the [AdminLTE dashboard](../Dashboard) if you do not want
authentication for all pages. The AdminLTE dashboard template, in file
cms.lua, shows how to use an authenticator for a subset of the pages.

## Notes:

We use camel case naming convention in the example code. The Lua table
type implements associative arrays. An associative array is an array
that can be indexed not only with numbers but also with keys such as
strings. We use the naming convention tableT when the table expects a
key based lookup and the naming convention tableL when the table is a
list (array).
