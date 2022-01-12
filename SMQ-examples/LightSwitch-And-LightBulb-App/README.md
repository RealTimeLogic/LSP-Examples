# SMQ Controlled Light Switch

This is the companion example for the
[Modern Approach to Embedding a Web Server in a Device](https://realtimelogic.com/articles/Modern-Approach-to-Embedding-a-Web-Server-in-a-Device)
tutorial.


The HTML files [www/bulb.html](www/bulb.html) and
[www/switch.html](www/switch.html) are designed to be dragged and
dropped into a browser window without you having to install any
software. However, you can also run a local server as follows:

Open switch.html and bulb.html in an editor.

In both files, replace the following line:
```
        var smq = SMQ.Client("wss://simplemq.com/smq.lsp");
```
with:
```
        var smq = SMQ.Client("ws://localhost/smq.lsp");
```

Start Mako Server as follows in this directory:
```
mako -l::broker
```

See the
[Mako Server command line video tutorial](https://youtu.be/vwQ52ZC5RRg)
for more information on how to start the Mako Server.

Drag and drop the modified switch.html and bulb.html into a browser
window to connect to your local broker.

---------------------------------------------

* SMQ documentation: https://realtimelogic.com/ba/doc/?url=SMQ.html
* SMQ (IoT) tutorials: https://makoserver.net/tutorials/

---------------------------------------------

# Light Bulb C Code

The directory "C" includes a C and C++ light bulb implementation. The
C code requires the
[SMQ C library](https://github.com/RealTimeLogic/SMQ) and optionally
the [JSON library](https://github.com/RealTimeLogic/JSON). The GitHub
repositories must be adjacent to each other when compiling the C code
using the included Linux Makefile or Visual Studio C++ build file;
e.g.:


``` shell
git clone https://github.com/RealTimeLogic/LSP-Examples.git
git clone https://github.com/RealTimeLogic/SMQ.git
#JSON is optional
git clone https://github.com/RealTimeLogic/JSON.git
```

See the C code comments for additional details.

Linux build:

``` shell
cd C
make
./bulb
```


