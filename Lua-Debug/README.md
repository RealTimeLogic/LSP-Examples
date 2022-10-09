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
2. You should see the Mako Server print the message "LDbgMon waiting
   for connection on port 4711" in the console window
3. Using VS, Select File -> Open Folder -> navigate to the
   Lua-Debug/www directory, and select this directory
4. Click the Run button (F5) to connect the debugger (operating as a
   client) to the debug monitor (server).
5. The debugger now connects to the Mako Server, and the debugger
   should, at this point, halt the execution in the application's
   .preload script

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
Lua startup code using VS. When the server idles, click the pause
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

The following instructions apply to using the debugger as a
TCP client. You may also use the instructions when the debugger operates
as a TCP server, but see the Gotchas section below for issues you
may run into.

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

### Auto Creating launch.json for remote debugging

The included FileServer app simplifies remote debugging as it sets up
a NetIo file server and auto creates the required Visual Studio Code
configuration file 'launch.json'. Open a command window on your host
computer (Windows/Linux/Mac) and start the File Server as follows:

``` shell
mako -l::FileServer
```

The File Server app should automatically open your browser and
navigate to the File Server. Using the File Server, navigate to the
application (sub directory) you want to debug, and copy the URL. Connect a
remote shell to the computer you want to run the Mako Server on. Type
the following in the shell and then paste in the URL.

``` shell
mako -l::<PASTE URL>
```

The following 1 minute video illustrates the complete remote debug setup:

[![IMAGE ALT TEXT HERE](http://img.youtube.com/vi/bSdwW58GcJ0/0.jpg)](http://www.youtube.com/watch?v=bSdwW58GcJ0)

The NetIo must be used when setting up a remote debug session as it
enables the remote Mako Server and Visual Studio code to work on the
same directory. See the
[NetIo section](https://realtimelogic.com/ba/examples/lspappmgr/readme.html#netio)
in the LSP Application Manager documentation for more information on
how the NetIo works.

### RTOS Example:

See the [Lua debug instructions for NXP's RT 1020 development board](https://realtimelogic.com/downloads/bas/rt1020/#LuaDebug) for information on how to debug Lua on an embedded RTOS powered board.

## Gotchas

The debug monitor embedded in the Mako Server implements the
[Debug Adapter Protocol](https://microsoft.github.io/debug-adapter-protocol/
) and can be used by any debugger implementing this protocol. Visual
Studio Code includes a Lua Debug plugin that you may use. We refer to
this combination as the debugger. This debugger has some gotchas and
minor incompatibilities with the debug monitor (server) as listed
below:

* The debugger provides a restart button (Ctrl-Shift-F5). Clicking
  this button makes the server restart the internal state of the
  program without restarting the process. The server's debugger
  connection will, for this reason, be closed and must be
  re-established. The debugger, when operating as a TCP network client
  auto reconnects, but a bug in the debugger makes the connection
  establishment fail. For this reason, if you plan on using the
  restart button, make sure to quickly click the Disconnect button
  after clicking the Restart button and then click the Continue
  button. You may also want to delay calling ldbgmon.connect() in your
  Lua code by using a timer or put the ldbgmon.connect() call in an
  LSP page that must be initiated by a browser.
* The exception breakpoints listed in the debugger will have no effect
  if enabled. These breakpoints require non standard modifications to
  the Lua VM.
* LSP files include both HTML and Lua code, which are not understood by
  the debugger and the debugger will show compilation errors when you
  open an LSP file. You can simply ignore these errors. However, you
  can set breakpoints in LSP files and step through code in LSP files.
* Are you debugging the correct file? The Barracuda App Server library
  (powering the Mako Server) provides an IO interface for each loaded
  app. The IO provides a relative path from the base for applications
  and the Lua VM. The debug monitor must, for this reason, search for
  the debugged file in all registered IOs and you may end up with the
  wrong file if you have the same file name in multiple apps. In
  particular, watch out for confusion in regards to debugging the
  app's .preload script.
* The server will be in run mode after the server has run through its
  initial startup code, including loading and running any startup code
  for your app such as the .preload script. You may then click the
  pause button in the debugger to halt the server, but note that the
  server is idling until a browser makes an LSP page execute or
  another event is triggered, such as a socket event or timer
  event. The server will halt as soon as an event triggers the
  execution of Lua code. In other words, loading static assets such as
  HTML files, images, etc., will not halt the server.
