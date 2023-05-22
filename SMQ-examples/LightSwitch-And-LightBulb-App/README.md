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
mako -l::www
```

For detailed instructions on starting the Mako Server, check out our [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and review the server's [command line options](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp) in our documentation.

Drag and drop the modified switch.html and bulb.html into a browser
window to connect to your local broker.

---------------------------------------------

* SMQ documentation: https://realtimelogic.com/ba/doc/?url=SMQ.html
* SMQ (IoT) tutorials: https://makoserver.net/tutorials/

---------------------------------------------

# Light Bulb C Code

The
[SMQ repository includes a C and C++ light bulb implementation](https://github.com/RealTimeLogic/SMQ#2-light-bulb-example).
The C code can be controlled via switch.html.
