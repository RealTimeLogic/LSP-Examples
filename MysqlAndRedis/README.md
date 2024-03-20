# MySQL and Redis Drivers

The subdirectory MySQL provides ready-to-use driver packages for **MySQL** and **Redis**, adapted from the OpenResty drivers. The MySQL package is based on [lua-resty-mysql](https://github.com/openresty/lua-resty-mysql), and the Redis package on [lua-resty-redis](https://github.com/openresty/lua-resty-redis). These drivers are exact copies, with an additional enhancement to the MySQL driver. Designed for Cosocket functionality, both drivers support the **Barracuda App Server (BAS)** and **OpenResty**, which facilitate Cosockets. However, they distinguish themselves in usage and the intricacies of their internal APIs. For BAS, Cosockets require encapsulation within a [ba.socket.event()](https://realtimelogic.com/ba/doc/en/lua/auxlua.html#ba_socket_event) function call. We provide supporting Lua code that effectively bridges the OpenResty and BAS API functionalities to accommodate this.

For an understanding of Cosockets and the differences between OpenResty's Cosockets and BAS, see the following links:

- [OpenResty Cosockets](https://api7.ai/learning-center/openresty/the-core-of-openresty-cosocket)
- [BAS Cosockets](https://realtimelogic.com/ba/doc/en/lua/SockLib.html#cosocket)

## Files

```
|   .config - Config file designed for Xedge
|   .preload - Package configuration logic
|
\---.lua
    |   bit.lua - Lua 5.1 bit simulator
    |   resty.lua - OpenResty API to BAS API
    |
    \---resty
            mysql.lua - OpenResty driver with one add-on
            redis.lua - OpenResty driver used as-is
            rsa.lua - OpenResty API to BAS API
            sha256.lua - OpenResty API to BAS API
```

We recommend packaging these files into a ready-to-run BAS zip file (deployed app) as follows:

```bash
cd MySQL
zip -D -q -u -r -9 ../MySQL.zip .
```

The above commands work on both Linux and Windows. The zip parameters ensure that the hidden files and directories are included. You may change the ZIP file name and remove the Redis or MySQL driver if the driver is not used.

## Example program

The www directory includes two LSP programs that let you test the MySQL and Redis drivers. To test using the Mako server, start the server as follows:

```bash
mako -l::MySQL.zip -l::www
```

Two LSP files are included within the www directory: one for the MySQL driver and another for the Redis driver. However, setting up MySQL and Redis environments is required before proceeding with the tests. The provided Linux command line instructions below are also compatible with WSL2 (Windows Subsystem for Linux).

```bash
sudo apt install docker
sudo dockerd
docker run -d --name some-redis -p 6379:6379 redis
docker run --name some-mysql -e MYSQL_DATABASE=world -e MYSQL_ROOT_PASSWORD=qwerty -p 3306:3306 -d mysql
```

The command **sudo dockerd** is only required on WSL2, as Linux should run the docker daemon automatically. On WSL2, run this command in a separate WSL2 console window.

We need to create a table in the **world** database for the MySQL test. Start the MySQL command line client as follows:

```bash
mysql -h 127.0.0.1 -u root -p
```

After starting the client, paste in the following commands:

```sql
USE world;

CREATE TABLE Persons (
     PersonID int,
     LastName varchar(255),
     FirstName varchar(255),
     Address varchar(255),
     City varchar(255)
);

insert into Persons (
    PersonID,
    LastName,
    FirstName,
    Address,
    City
)
VALUES(1,"Bond","James"," Old Bond Street","London");
```

You are now ready to run the two LSP examples; navigate to:

- http://localhost:portno/MySQL.lsp
- http://localhost:portno/Redis.lsp

**Note:** if you use WSL2, the Mako Server must also run on WSL2. It's possible to run the Mako Server on Windows, but you would need to set up a proxy using the netsh command. When using WSL2, you can use your browser on Windows, but do not navigate to localhost; navigate to the WSL2 IP address, which can be found by running the ipconfig command.

## Using the MySQL Driver

### Sockets in the Barracuda App server

Sockets within BAS operate in a blocking mode by default. Consequently, the drivers will use blocking socket calls unless they are encapsulated within a [ba.socket.event()](https://realtimelogic.com/ba/doc/en/lua/auxlua.html#ba_socket_event) call. It is important to note that blocking sockets should only be used within an LSP (Lua Server Page). The two LSP examples provided demonstrate the correct usage of blocking sockets. For any other cases, as previously discussed, it is imperative to wrap your code with a `ba.socket.event()` call, transforming the code execution into a non-blocking Cosocket operation.

### MySQL Persistent Database Connection Example

The MySQL driver features an enhancement that facilitates the use of a persistent database Cosocket connection, offering a more efficient and streamlined approach. Below is an example illustrating how to leverage this API:

```lua

local mysql = require"resty.mysql"
local db,err = mysql:new()
if not db then
   trace("mysql:new failed:",err)
   return
end

-- Flag to control the running state; remains true until 'onunload' is executed
local running = true

-- Configuration settings for the database connection
local cfg = {
   host = "localhost",
   port = 3306, -- Default MySQL port number
   database = "world", -- Name of the database
   user = "root", -- Database username
   password = "qwerty" -- Database password
}

-- Callback function for handling the database connection response
local function cb(ok, err, errno, sqlstate)
   -- Log the connection status
   trace("Connect", ok, err, errno, sqlstate)
   -- Continue attempting to connect until 'onunload' is called
   return running
end

-- Initiates a persistent asynchronous connection to the database with
-- the provided configuration and callback
db:async(cfg, cb)

-- Execute a query within the DB cosocket
db:execute(function()
   -- Perform a query to select the first 50 rows from the 'Persons'
   -- table, ordered by 'PersonID'
   local res, err, errno, sqlstate =
      db:query("select * from Persons order by PersonID limit 50")
   -- Check if the query was unsuccessful
   if not res then
      -- Log the error details
      trace("bad result #1: ", err, ": ", errno, ": ", sqlstate, ".")
      return
   end

   -- Iterate over each row in the query result
   for _, row in ipairs(res) do
      -- Print each column key and value for the row
      for k, v in pairs(row) do
         trace('>', k, v)
      end
   end
end)

-- 'onunload' function to gracefully shut down the database connection
function onunload()
   -- Update the running state to false to stop the connection attempts
   running = false
   db:close()
end
```

### MySQL Persistent Database Connection API

The two methods, db:async and db:execute, have been added to the MySQL driver. We recommend studying the implementation of this logic, found at the end of [mysql.lua](MySQL/.lua/resty/mysql.lua).

**db:async(config, callback)**

Initiate a persistent database connection.

Arguments:
- config is the parameter passed into the method db:connect(config). See the [Redis MySQL Lua API](https://github.com/openresty/lua-resty-redis) for details.
- callback is a function called when the database connection succeeds or fails. It receives the three arguments returned by db:connect(). If the connection fails, the function may return true to re-try the connection. The callback is also called if the persistent connection should break.

**Db:execute([function])**

Queue the execution of the provided function and run the function within the Cosocket environment. The function returns the number of queued functions. You may call this function without arguments if you need to know the number of queued operations.

## Limitations

The OpenResty compatibility layer is currently not implementing the connection pool; thus a socket added to the pool is simply closed.
