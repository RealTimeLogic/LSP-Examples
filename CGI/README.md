# CGI Plugin and Examples

The Barracuda App Server and Mako Server do not come with a CGI
plugin. The CGI implementation in this example is implemented in Lua
and uses the
[forkpty plugin](https://realtimelogic.com/ba/doc/?url=auxlua.html#forkptylib)
for the external process management. Note that the forkpty plugin is
only available on the following platforms: Linux, Mac, and QNX.

## Instructions:

1. Copy the CGI scripts in the 'scripts' directory to /tmp/cgi-test/
```console
   mkdir -p /tmp/cgi-test/
   cp scripts/* /tmp/cgi-test/
```
2. Make sure the scripts are 'executable'
   chmod +x /tmp/cgi-test/*
3. Start the Mako Server and load the 'www' directory
   mako -l::www

For detailed instructions on starting the Mako Server, check out our [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and review the server's [command line options](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp) in our documentation.

After starting the Mako Server, use a browser and navigate to
http://localhost:portno, where portno is the HTTP port number used by
the Mako Server (printed in the console). You should be redirected to
http://localhost/cgi/sh.cgi. The file 'sh.cgi' is a basic CGI
shell script.

A Python script is also included. Execute the Python script as follows:

http://localhost/cgi/python.cgi?textcontent=Hello%20World


## The example's Source Code Files:

* www/index.lsp - Redirects to /cgi/sh.cgi
* www/.preload - Loads the CGI Lua module, creates a CGI directory,
  and inserts the directory into the
  [virtual file system](https://realtimelogic.com/ba/doc/?url=GettingStarted.html#VFS)
* www/.lua/cgi.lua - The CGI module

### CGI scripts:

* scripts/sh.cgi - Basic shell based script
* scripts/python.cgi - Python script accepting 'form data'

### Details:

The .preload script, which is executed when the application is loaded, initializes the CGI plugin as follows:

``` lua
local cgidir=cgi.create("/tmp/cgi-test/","cgi")
dir:insert(cgidir,true) -- Insert cgi directory as child object
```

The above code creates a CGI directory with the base path
"/tmp/cgi-test/". You should change this path to a path suitable for
your application.

All Mako server applications have a pre-defined
[LSP directory object](https://realtimelogic.com/ba/doc/?url=ua.html#ba_create_resrdr)
called 'dir' and the last line above inserts the CGI directory as a
sub directory of the application's directory. See the
[Virtual File System Documentation](https://realtimelogic.com/ba/doc/?url=GettingStarted.html#VFS)
for details.

## Security

All forms of parent directory lookup such as '..' are removed by the
server prior to searching the virtual file system for a directory
object matching the URL pathname. For example,
http://address/cgi/../somexec will be translated to
http://address/somexec and the CGI directory object will not be called
since the pathname does not match the CGI directory path name. In any
event, CGI directories should preferably be protected by an
[authentication object](https://realtimelogic.com/ba/doc/?url=lua.html#auth_overview).
