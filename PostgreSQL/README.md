# How to use one persistent PostgreSQL connection object for all DB operations

This is the companion example for the tutorial: [Using Lua to Access a PostgreSQL Database](https://makoserver.net/articles/Using-Lua-to-Access-a-PostgreSQL-Database).

## Instructions:

1. Create an ElephantSQL account and compile the required C code as explained in the tutorial: [Using Lua to Access a PostgreSQL Database](https://makoserver.net/articles/Using-Lua-to-Access-a-PostgreSQL-Database)
2. Open mako.conf in an editor and set the required attributes in table 'cinfo' with values copied from your ElephantSQL account
3. Save mako.conf
4. In a command window, navigate to the directory LSP-Examples/PostgreSQL and start the mako server as follows: mako
5. The application should connect to your ElephantSQL instance and you should see the folowing being printed: DB connected:	yes
6. Open a browser and navigate to http://localhost:portno, where portno is the server's listening port
7. Enter data in the HTML form and click submit


## Files

* www/.preload -- Creates a 'pg' instance
* www/.lua/pg.lua -- Library 'pg' simplifies using library 'pgsql' (pgsql.so) and maintains one DB connection
* www/index.lsp -- Example code
