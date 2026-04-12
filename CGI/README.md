# CGI Plugin and Examples

## Overview

The Barracuda App Server and Mako Server do not include a CGI plugin by default. This example provides a CGI implementation written in Lua. It uses the [forkpty plugin](https://realtimelogic.com/ba/doc/?url=auxlua.html#forkptylib) for external process management, so it is intended for platforms where that plugin is available: Linux, macOS, and QNX.

## Files

- `www/.preload` - Creates the CGI directory object and inserts it into the application's [virtual file system](https://realtimelogic.com/ba/doc/?url=GettingStarted.html#VFS).
- `www/.lua/cgi.lua` - CGI compatibility module.
- `www/index.lsp` - Redirects the browser to the shell CGI example.
- `scripts/sh.cgi` - Simple shell-based CGI script.
- `scripts/python.cgi` - Python CGI script that accepts form data.

## How to run

1. Copy the CGI scripts to a test directory:

```bash
mkdir -p /tmp/cgi-test/
cp scripts/* /tmp/cgi-test/
```

2. Make the scripts executable:

```bash
chmod +x /tmp/cgi-test/*
```

3. Start the example:

```bash
cd CGI
mako -l::www
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

After the server starts, open `http://localhost:portno`, where `portno` is the HTTP port shown in the console. You should be redirected to `http://localhost/cgi/sh.cgi`.

To test the Python CGI script directly, open:

```text
http://localhost/cgi/python.cgi?textcontent=Hello%20World
```

## How it works

The startup script enables module loading with `mako.createloader(io)`, loads `cgi.lua`, creates a CGI directory rooted at `/tmp/cgi-test/`, and inserts that directory into the app's VFS:

```lua
local cgidir = cgi.create("/tmp/cgi-test/", "cgi")
dir:insert(cgidir, true)
```

Inside `cgi.lua`, each incoming request is translated into CGI environment variables and launched with `ba.forkpty(...)`. The module captures the child process output, parses the CGI headers, forwards the headers to the BAS response object, and then streams the body back to the client.

The three main source files each have a distinct role:

- `index.lsp` redirects the browser into the example CGI endpoint
- `.preload` mounts the CGI directory into the VFS
- `.lua/cgi.lua` implements the CGI adapter itself

## Notes / Troubleshooting

- Change `/tmp/cgi-test/` in `www/.preload` if you want to use a different CGI root path.
- BAS strips parent-directory traversal such as `..` before VFS lookup, which helps protect the CGI directory from path traversal attempts.
- CGI directories should still preferably be protected with an [authentication object](https://realtimelogic.com/ba/doc/?url=lua.html#auth_overview) in real deployments.
