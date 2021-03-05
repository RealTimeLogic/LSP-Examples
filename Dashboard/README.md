# Build an Interactive Dashboard App

This is the companion example for the [How to Build an Interactive Dashboard App](https://makoserver.net/articles/How-to-Build-an-Interactive-Dashboard-App) tutorial.

## Prepare the Example

You do not need to run the git commands below in a command window, but
you must make sure you create the same structure. The example requires
the original AdminLTE code. The script 'build.lua' extracts a number
of example pages from AdminLTE and copies the content into
AdminLTE.new with the format expected by the Mako Server powered
dashboard version.

1. Open a command window in a suitable directory
2. Download AdminLTE: git clone https://github.com/ColorlibHQ/AdminLTE.git
3. Download the LSP examples: git clone https://github.com/RealTimeLogic/LSP-Examples
4. Download [xlua for your platform](https://makoserver.net/download/overview/)
5. Run:
    Win:   xlua LSP-Examples\Dashboard\build.lua AdminLTE
    Linux: ./xlua LSP-Examples/Dashboard/build.lua AdminLTE
6. Copy all files in LSP-Examples/Dashboard/source/ to AdminLTE.new/ e.g.: cp -r LSP-Examples/Dashboard/source/. AdminLTE.new
7. Copy the two directories 'dist' and 'plugins' from AdminLTE/ to AdminLTE.new/

## Run the example, using the Mako Server, as follows:

```
mako -l::AdminLTE.new
```

See the [Mako Server command line video tutorial](https://youtu.be/vwQ52ZC5RRg) for more information on how to start the Mako Server.

After starting the Mako Server, use a browser and navigate to
http://localhost:portno, where portno is the HTTP port number used by
the Mako Server (printed in the console).

## 'LSP-Examples/Dashboard' Files:

```
|   build.lua -- Initial script used for extracting data from AdminLTE and inserting into AdminLTE.new
|
\---source -- Everything below should be copied to AdminLTE.new such that the directory includes AdminLTE.new/.preload
    |   .preload -- Loads cms.lua when server starts
    |
    \---.lua
        |   cms.lua -- Mini Content Management System (CMS engine)
        |
        \---www
                template.lsp -- AdminLTE page converted to a template page and used by CMS engine
```

## Notes:

The script 'build.lua' also creates the menu information file
AdminLTE.new/.lua/menu.json, a file that should normally be hand
crafted. We create this file automatically for the purpose of this
demo; creating the file automatically enables us to dynamically
extract and use most of the pages in the AdminLTE directory. The
extraction process is not perfect and you should consult the original
AdminLTE pages for details.

## How to Create Your Own AdminLTE Based Dashboard Application

1. Copy all files in LSP-Examples/Dashboard/source/ to your-app/
2. Copy the directory 'dist' from AdminLTE/ to your-app/
2. Optionally copy the directory 'plugins' from AdminLTE/ to your-app/ or copy the plugins you plan on using, if any
3. Create the LSP pages that should be part of your application and put them in your-app/.lua/www/ or in a sub-directory
4. Hand-craft your-app/.lua/menu.json
5. Edit your-app/.lua/www/template.lsp as needed and make sure any
   JavaScript file required by the optional plugins you are using are
   included at the end of the file.

### menu.json format:

```
menu-list:
[
    menu-element1,
    menu-element2,
    ....
]

menu-element: // Leaf node
{
    "name": "link name",
    "class": "nav-icon", // And additional AdminLTE classes
    "href": "path"
}

menu-element: // directory
{
    "name": "link name",
    "class": "nav-icon", // And additional AdminLTE classes
    "href": "relative path" // or "#" if no page is associated with the directory
    "sub": menu-list
}
```
