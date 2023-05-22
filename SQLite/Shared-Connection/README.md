# SQLite Shared Connection Example

This is the companion example for the [Lua-SQLite and LSP Considerations](http://realtimelogic.com/ba/doc/?url=luasql-lsp-considerations.html) tutorial. See the tutorial [Understanding SQLITE_BUSY](https://activesphere.com/blog/2018/12/24/understanding-sqlite-busy) for a detailed explanation on SQLite locking.

Run the example, using the Mako Server, as follows:

```
cd SQLite/Shared-Connection
mako -l::www
```

For detailed instructions on starting the Mako Server, check out our [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and review the server's [command line options](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp) in our documentation.

1. After starting the Mako Server as instructed above, navigate to http://localhost.
2. The database is initially empty. Enter data and press submit to start inserting data into the database.
3. To automate insertion of data, navigate to the URL: http://localhost?auto=.
4. Javascript code executing in the browser will now auto post new data as soon as the page loads.


