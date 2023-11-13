# TraceLogger Client

The TraceLogger Client is designed to connect to another Barracuda App Server enabled device and log data from this device without having to use the [HTML based TraceLogger Client](https://realtimelogic.com/ba/doc/?url=auxlua.html#tracelogger).

Use this TraceLogger Client as follows:

1. Open TraceLogger/mako.conf in an editor.
2. Change the TraceLogger peer (trpeer) variable. This variable must be the name or IP address of the device running the Barracuda App Server.
3. Start the Mako Server as follows:

    ```
    cd TraceLogger
    mako -l::www
    ```

    For detailed instructions on starting the Mako Server, please refer to our [Mako Server command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and review the [server's command line options](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp) in our documentation.

4. The peer's log will be printed in the console or saved in mako.log if the server runs as a background process. You may also view the trace using the local server's TraceLogger by navigating to http://localhost or directly to http://localhost/rtl/tracelogger/
