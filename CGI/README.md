#CGI Plugin and Examples

The Barracuda App Server and Mako Server do not come with a CGI
plugin. The CGI implementation in this example is implemented in Lua
and uses the
[forkpty plugin](https://realtimelogic.com/ba/doc/?url=auxlua.html#forkptylib)
for the external process management. Note that the forkpty plugin is
only available on the following platforms: Linux, Mac, and QNX.

## Instructions:

1. Copy the CGI scripts in the 'scripts' directory to /tmp/cgi-test/
   mkdir -p /tmp/cgi-test/ && cp scripts/* /tmp/cgi-test/
2. Make sure the scripts are 'executable'
   chmod +x /tmp/cgi-test/*
3. Start the Mako Server and load the 'www' directory
   mako -l::www

See the
[Mako Server command line video tutorial](https://youtu.be/vwQ52ZC5RRg)
for more information on how to start the Mako Server.

After starting the Mako Server, use a browser and navigate to
http://localhost:portno, where portno is the HTTP port number used by
the Mako Server (printed in the console). You should be redirected to http://localhost/cgi/sh.cgi. This is a very basic CGI shell scripts.

A basic Python script is also included. Execute the Python script as follows:

http://localhost/cgi/python.cgi?textcontent=Hello%20World


## The example's Source Code Files:

* www/index.lsp - Redirects to /cgi/sh.cgi
* www/.preload - Loads the CGI Lua module, creates a CGI directory,
  and inserts the directory into the virtual file system
* www/.lua/cgi.lua - The CGI module

CGI scripts:
scripts/sh.cgi - Basic shell based script
scripts/python.cgi - Python script accepting 'form data'




