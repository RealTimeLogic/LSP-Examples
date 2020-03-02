# SMQ Controlled Light Switch

This is the companion example for the [Modern Approach to Embedding a Web Server in a Device](https://realtimelogic.com/articles/Modern-Approach-to-Embedding-a-Web-Server-in-a-Device) tutorial.


The HTML files bulb.html and switch.html are designed to be dragged
and dropped into a browser window without you having to install any
software, however, you can also run a local server as follows:

Open switch.html and bulb.html in an editor

In both files, replace the following line:
```
        var smq = SMQ.Client("wss://simplemq.com/smq.lsp");
```
with:
```
        var smq = SMQ.Client(SMQ.wsURL("/smq.lsp"));
```

Start Mako Server as follows in the parent directory:
```
cd SMQ-examples
mako -l::LightSwitch-And-LightBulb-App 
```

Navigate to:
http://localhost[:portno]/bulb.html
http://localhost[:portno]/switch.html

See the
[Mako Server command line video tutorial](https://youtu.be/vwQ52ZC5RRg)
for more information on how to start the Mako Server.


---------------------------------------------

SMQ documentation: https://realtimelogic.com/ba/doc/?url=SMQ.html
SMQ (IoT) tutorials: https://makoserver.net/tutorials/

