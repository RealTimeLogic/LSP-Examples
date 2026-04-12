# TraceLogger Client

## Overview

This example shows how to connect to the trace output of another Barracuda App Server enabled device without using the built-in HTML TraceLogger client. It is intended as a lightweight trace-forwarding client that runs locally and writes the peer's trace output to the console or log.

## Files

- `mako.conf` - Holds the TraceLogger peer configuration, including `trpeer`.
- `www/.preload` - Starts the TraceLogger client connection.
- `www/index.lsp` - Simple page that gives you access to the local server UI while the trace client is running.

## How to run

1. Open `TraceLogger/mako.conf` in an editor.
2. Change the TraceLogger peer variable `trpeer` so it points to the BAS-enabled device you want to monitor.
3. Start the example:

```bash
cd TraceLogger
mako -l::www
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

## How it works

The startup logic connects to the configured peer's trace service and forwards the incoming trace stream to the local server environment. If the Mako Server is running in the foreground, you see the trace output in the console. If it is running in the background, the trace output is written to `mako.log`.

## Notes / Troubleshooting

- You can also open the local TraceLogger UI at `http://localhost` or directly at `http://localhost/rtl/tracelogger/`.
- If no trace data appears, double-check the peer address in `mako.conf` and confirm that the remote BAS device exposes trace output.
