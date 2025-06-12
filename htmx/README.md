[htmx](https://htmx.org/) is a lightweight JavaScript library that lets you update parts of a web page by sending simple HTTP requests and swapping in server-rendered HTML; no client-side rendering or JSON required. This makes it a perfect match for Lua Server Pages (LSP), which excels at generating dynamic HTML on the server. Together, they create a clean, efficient way to build interactive web interfaces for embedded systems without the complexity of modern frontend frameworks.

## Example 1: 

This is the companion example for the beginner tutorial [LSP + htmx: A Powerful Duo for Embedded Web Apps](https://realtimelogic.com/articles/LSP-htmx-A-Powerful-Duo-for-Embedded-Web-Apps).

Run the example, using the Mako Server, as follows:

```
cd LSP-Examples/htmx
mako -l::introduction
```

For detailed instructions on starting the Mako Server, check out our [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and review the server's [command line options](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp) in our documentation.

After starting the Mako Server, use a browser and navigate to
http://localhost:portno, where portno is the HTTP port number used by
the Mako Server (printed in the console).
