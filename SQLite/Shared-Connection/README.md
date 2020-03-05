# SQLite Shared Connection Example

This is the companion example for the [Lua-SQLite and LSP Considerations](http://realtimelogic.com/ba/doc/?url=luasql-lsp-considerations.html) tutorial.

Run the example, using the Mako Server, as follows:

```
cd SQLite/Shared-Connection
mako -l::www
```

See the [Mako Server command line video tutorial](https://youtu.be/vwQ52ZC5RRg) for more information on how to start the Mako Server.

1. After starting the Mako Server as instructed above, navigate to http://localhost.
2. The database is initially empty. Enter data and press submit to start inserting data into the database.
3. To automate insertion of data, navigate to the URL: http://localhost?auto=.
4. Javascript code executing in the browser will now auto post new data as soon as the page loads.


