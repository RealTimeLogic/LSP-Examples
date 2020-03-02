# Linux Web Shell

The Linux Web Shell is a web-based SSH alternative. The Lua server side code shows how to use function [ba.forkpty()](https://realtimelogic.com/ba/doc/?url=auxlua.html#forkptylib). See the article [Linux Web Shell](https://makoserver.net/articles/Linux-Web-Shell) for details.

Run the example, using the Mako Server, as follows:

```
cd Web-Shell
mako -l::www
```

See the [Mako Server command line video tutorial](https://youtu.be/vwQ52ZC5RRg) for more information on how to start the Mako Server.

After starting the Mako Server, use a browser and navigate to http://localhost:portno, where portno is
the HTTP port number used by the Mako Server (printed in the console).


### Resources:
* .preload: Manages a bash shell via ba.forkpty and manages the server side SMQ connection
* index.lsp: Browser terminal uses the xterm.js lib and sets up an SMQ connection with server
* xterm-compressed.js: Compressed version of xterm.js and fit.js: https://xtermjs.org/
