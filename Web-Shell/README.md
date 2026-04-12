# Linux Web Shell

## Overview

The Linux Web Shell is a browser-based alternative to SSH. The example focuses on the server-side use of [`ba.forkpty()`](https://realtimelogic.com/ba/doc/?url=auxlua.html#forkptylib) together with an SMQ-based browser terminal. See the article [Linux Web Shell](https://makoserver.net/articles/Linux-Web-Shell) for the full walkthrough.

## Files

- `www/.preload` - Starts and manages the shell process with `ba.forkpty()` and sets up the server-side SMQ connection.
- `www/index.lsp` - Serves the browser terminal UI and creates the client-side SMQ connection.
- `www/xterm.js` and `www/xterm.css` - Terminal library assets used by the browser UI.

## How to run

Start the example with the Mako Server:

```bash
cd Web-Shell
mako -l::www
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

After the server starts, open `http://localhost:portno`, where `portno` is the HTTP port shown in the console.

## How it works

The server starts a shell through `ba.forkpty()`, which gives the application a pseudo-terminal connected to the shell process. The browser page uses `xterm.js` for terminal rendering and communicates with the server through SMQ so user input and shell output can move back and forth in real time.

An online testing server is also available at:

https://tutorial.realtimelogic.com/shell/

The testing server includes a few ASCII-powered games and tools:

| Command | What it is | How to exit |
| --- | --- | --- |
| `sl` | Steam Locomotive | N/A |
| `cowsay` | [cowsay](https://en.wikipedia.org/wiki/Cowsay) | N/A |
| `cmatrix` | "The Matrix" | `CTRL-C` |
| `bastet` | Terminal Tetris | `CTRL-C` |
| `mc` | Midnight Commander | `F10` |
| `lynx` | The Lynx browser | `q` |
| `christmas.sh` | Christmas tree | `CTRL-C` |
| `fireworks` | Fireworks | `CTRL-C` |

Example commands:

```text
cowsay -f ghostbusters Who you Gonna Call
fortune | cowsay
fortune | cowsay -f tux
toilet -t -f mono12 -F metal "Mako Server"
lynx https://realtimelogic.com/articles/Embedded-Web-Server-Tutorials
```

## Notes / Troubleshooting

- This example is Linux-oriented because it depends on `ba.forkpty()`.
- The final `lynx` example is useful for reading the Real Time Logic tutorials from inside the shell itself.
- More command ideas are available here: https://www.binarytides.com/linux-fun-commands/
