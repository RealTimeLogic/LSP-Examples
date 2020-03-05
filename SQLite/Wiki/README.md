# Basic Wiki Engine

This is the companion example for the [URL to Database Mapping Tutorial](https://makoserver.net/articles/URL-to-Database-Mapping-Tutorial) tutorial.

This example implements a basic wiki engine by using a [directory function](https://realtimelogic.com/ba/doc/?url=lua.html#ba_dir) and SQLite for data storage.

Run the example, using the Mako Server, as follows:

```
cd SQLite/Tutorial
mako -l::www
```

See the [Mako Server command line video tutorial](https://youtu.be/vwQ52ZC5RRg) for more information on how to start the Mako Server.

After starting the Mako Server, use a browser and navigate to
http://localhost:portno, where portno is the HTTP port number used by
the Mako Server (printed in the console).

You can create a new page by entering a non existing URL such as
http://localhost/my-page. Enter any textual data in the form and click
the submit button. You can keep creating pages by using new URLs. A
list of all pages created is shown at the main URL (http://localhost).
