# How to Debug Lua Code Using Visual Studio Code

This is the companion example for the tutorial:
[Lua and LSP Debugging](https://makoserver.net/articles/Lua-and-LSP-Debugging).

## Prerequisites

1. Download the latest [Mako Server](https://makoserver.net/download/overview/)
2. Download and install [Visual Studio Code](https://code.visualstudio.com/) for your platform
3. Download and install [Lua Debug](https://marketplace.visualstudio.com/items?itemName=actboy168.lua-debug) for Visual Studio Code
4. Follow the instructions below:

## Debugging Instructions

Run the example, using the Mako Server, as follows:

``` shell
cd Lua-Debug
mako -l::www
```

See the
[Mako Server command line video tutorial](https://youtu.be/vwQ52ZC5RRg)
for more information on how to start the Mako Server. See the
[Getting Started with the Mako Server](https://makoserver.net/documentation/getting-started/)
command line guide for additional instructions.

### Initial Test Instructions

1. Start Mako Server as instructed above
2. You should see the Mako Server continually printing "cannot
   connect to debugger" messages in the console window
3. Using VS, Select File -> Open Folder -> navigate to the
   Lua-Debug/www directory, and select this directory
4. Click the Run button (F5) to start VS as a debug server
5. Mako Server now connects to VS, and the debugger should at this
   point halt the execution in the application's .preload script

The Mako Server's integrated debug monitor will immediately attempt to
connect to Visual Studio Code (VS) as soon as the 'www' Lua
application is loaded by the Mako Server. You will see a number of
failed connection attempts. These error messages will print until
you start VS; open the www directory in VS; and click the Run
button. VS uses the configuration information in .vscode/launch.json
and starts VS as a debug server as soon as you click the Run button
(F5). The Mako Server should then connect and the debug session
start.

### Configuring VS

At this point, you can step through the code, but you cannot set
breakpoints since the .preload script is not recognized as a Lua
script. To make VS recognize .preload and other Mako Server extensions
as Lua scripts, perform the following steps:

1. Using VS, navigate to the [settings page](https://code.visualstudio.com/docs/getstarted/settings) (File -> Preferences -> Settings).
2. Enter "associations" in the "search settings" field, and click the
   "Edit in settings.json" link
3. Add the following to the "files.associations" JSON section:
``` json
   "*.lsp":"lua",
    ".preload":"lua",
    ".config":"lua"
```
4. Save the settings.json file (Ctrl-S)
5.  You should now restart the debug session (F5); you may have to
    restart the Mako Server
6. The debugger should halt the execution in the application's
   .preload script
7. Follow the debugging instructions provided in the comments in the
   .preload script

### Debugging LSP files

The Mako Server will be idle after you have run through the initial
Lua startup code using VS. When the server idles click the pause
button in VS, open a browser, and navigate to http://localhost. VS
will then halt the LSP page at the top of the file. See the comments
in index.lsp for additional debugging tips.

### Editing and restarting the debug sessions

LSP files may be changed in the debugger and the new changes take
effect the next time you use a browser and navigate to the LSP file.

You may also change other Lua files using VS such as the application's
.preload script and Lua modules (such as the example's
Markow-Chain.lua file). The server must be restarted for any changes
to take effect, except for LSP files. You may either terminate and
restart the server or click the restart button (circle button) in the
VS debugger. When clicking the restart button, the internal state of
the Mako Server is restarted without restarting the executable. This
construction makes it super fast to restart the server after Lua code
has been modified.

#### Restart a debug session as follows:

1. Click the restart button in VS
2. The Mako Server's internal state restarts
3. After approximately one second, the Run button appears in the debugger
4. Click the Run button to resume debugging

## The example's Source Code Files:
* www/.vscode/launch.json - Visual Studio Code launch (debug) config file.
* www/.lua/Markow-Chain.lua  - File to step into and set breakpoints in.
* www/.preload - The app's Lua startup script including code for
  loading the Mako Server's integrated debugger monitor. Visual Studio
  Code will show this file as soon as the debug session starts.
* index.lsp -- Example LSP file. You can also set breakpoints in and
  step through LSP files.

## Mapping Directories (required)

For the VS debugger to be in sync with the server, the working
directory (or directories) must be mapped. All applications running in
the server have their own
[IO instance](https://realtimelogic.com/ba/doc/?url=lua.html#ba_ioinfo).
These IO instances must be mapped to the physical (absolute) path used
by the VS debugger. You will not be able to set breakpoints without
this mapping, but you can step into Lua files without mapping since
the VS debugger can load the source code from the Mako Server. For
example, you may inspect the Mako Server's .config file by clicking on
the .config file in the "CALL STACK" pane. The .config file is inside
mako.zip and cannot be mapped to an absolute path.

This Lua example does not need to be manually mapped when the VS
debugger and Mako Server are running on the same computer. An auto
mapping is set up for the current working folder when a
.vscode/launch.json is found inside the working folder.

### Setting up "sourceMaps" in launch.json

If the VS debugger and server are on different machines or if you are
debugging more than one application at a time, a "sourceMaps"
attribute must be added to
[launch.json](https://code.visualstudio.com/docs/editor/debugging#_launchjson-attributes).

The "sourceMaps" attribute must be constructed as follows:

``` json
"sourceMaps": [
    [
        "VS debugger path A",
        "Mako Server base path A",
    ],
    [
        "VS debugger path B",
        "Mako Server base path B",
    ]
]
```

See the source mapping example in Lua-Debug/www/.vscode/launch.json
for more information.
