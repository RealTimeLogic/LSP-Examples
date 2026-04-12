# MySQL and Redis Drivers

## Overview

The `MySQL` subdirectory contains ready-to-use driver packages for **MySQL** and **Redis**, adapted from the OpenResty drivers. The MySQL package is based on [lua-resty-mysql](https://github.com/openresty/lua-resty-mysql), and the Redis package is based on [lua-resty-redis](https://github.com/openresty/lua-resty-redis).

These drivers are intended for Cosocket-style use. BAS supports the same general model, but the execution environment differs from OpenResty, so this example includes compatibility code that bridges the OpenResty-style APIs to BAS socket behavior.

Background reading:

- [OpenResty Cosockets](https://api7.ai/learning-center/openresty/the-core-of-openresty-cosocket)
- [BAS Cosockets](https://realtimelogic.com/ba/doc/en/lua/SockLib.html#cosocket)

## Files

- `MySQL/.config` and `MySQL/.preload` - Packaging and module-loading support for the driver bundle.
- `MySQL/.lua/resty/mysql.lua` - OpenResty MySQL driver with the added BAS-specific persistent-connection helpers.
- `MySQL/.lua/resty/redis.lua` - OpenResty Redis driver.
- `MySQL/.lua/resty.lua`, `rsa.lua`, `sha256.lua`, `bit.lua` - Compatibility support modules.
- `www/.preload` - Startup message for the example pages.
- `www/MySQL.lsp` - MySQL test page.
- `www/Redis.lsp` - Redis test page.

The reusable package layout inside `MySQL/` is intentionally close to the original OpenResty structure:

```text
|   .config
|   .preload
|
\---.lua
    |   bit.lua
    |   resty.lua
    |
    \---resty
            mysql.lua
            redis.lua
            rsa.lua
            sha256.lua
```

Keeping that structure intact makes `require "resty.mysql"` and `require "resty.redis"` work the way OpenResty developers expect, while the BAS compatibility layer handles the runtime differences underneath.

## How to run

If you want to package the reusable drivers into a BAS ZIP app, create the ZIP from the `MySQL` directory:

```bash
cd MySQL
zip -D -q -u -r -9 ../MySQL.zip .
```

The hidden files and directories are intentionally included.

To run the example pages with Mako Server:

```bash
mako -l::MySQL.zip -l::www
```

Before testing, start Redis and MySQL. The Linux commands below also work on WSL2:

```bash
sudo apt install docker
sudo dockerd
docker run -d --name some-redis -p 6379:6379 redis
docker run --name some-mysql -e MYSQL_DATABASE=world -e MYSQL_ROOT_PASSWORD=qwerty -p 3306:3306 -d mysql
```

On WSL2, `sudo dockerd` must run in a separate WSL2 console. On most Linux systems, the Docker daemon already runs as a service.

Create the sample table for the MySQL test:

```bash
mysql -h 127.0.0.1 -u root -p
```

Then execute:

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

Then open:

- `http://localhost:portno/MySQL.lsp`
- `http://localhost:portno/Redis.lsp`

If you use WSL2, the Mako Server should also run inside WSL2. It is possible to run Mako on Windows and proxy into WSL2, but that adds extra setup. When the server runs inside WSL2, use the WSL2 IP address in the browser rather than `localhost`.

## How it works

The example LSP pages show both execution styles:

- direct blocking socket use inside an LSP page
- OpenResty-style cosocket use wrapped in `ba.socket.event(...)`

`MySQL.lsp` opens a connection, queries the `Persons` table, prints the result, then runs the same test again through `ba.socket.event(...)`. `Redis.lsp` performs a similar pattern with basic set/get operations plus a pipeline example.

That side-by-side structure is useful because the examples show that the driver API itself does not need to change much when you move from blocking LSP execution to the BAS cosocket model.

The Redis page is especially useful for checking the OpenResty compatibility layer because it exercises:

- normal `connect`, `set`, and `get` calls
- the `ngx.null` compatibility behavior
- pipelined commands with `init_pipeline()` and `commit_pipeline()`

The MySQL driver also includes two BAS-specific helper methods:

- `db:async(config, callback)` - Starts a persistent asynchronous database connection and optionally retries through the callback.
- `db:execute(function)` - Queues work to run inside the database cosocket environment.

That persistent-connection logic is implemented near the end of `MySQL/.lua/resty/mysql.lua`.

### Persistent MySQL connection example

The added API makes it possible to keep one database cosocket alive and queue work onto it:

```lua
local mysql = require"resty.mysql"
local db,err = mysql:new()
if not db then
   trace("mysql:new failed:",err)
   return
end

local running = true
local cfg = {
   host = "localhost",
   port = 3306,
   database = "world",
   user = "root",
   password = "qwerty"
}

local function cb(ok, err, errno, sqlstate)
   trace("Connect", ok, err, errno, sqlstate)
   return running
end

db:async(cfg, cb)

db:execute(function()
   local res, err, errno, sqlstate =
      db:query("select * from Persons order by PersonID limit 50")
   if not res then
      trace("bad result #1: ", err, ": ", errno, ": ", sqlstate, ".")
      return
   end
   for _, row in ipairs(res) do
      for k, v in pairs(row) do
         trace('>', k, v)
      end
   end
end)

function onunload()
   running = false
   db:close()
end
```

### Persistent API summary

- `db:async(config, callback)` starts the persistent connection flow.
- `callback` receives the same connection results as `db:connect(config)`.
- If the callback returns `true` after a failure, the code retries the connection.
- `db:execute(function)` queues work to run inside the same database cosocket environment.
- Calling `db:execute()` without a function returns the queued-operation count.

The recommendation from the original example still applies: study the implementation at the end of `MySQL/.lua/resty/mysql.lua` if you plan to use the persistent connection pattern in your own app.

That part of the file is where the BAS-specific enhancements live, so it is the best place to compare the original OpenResty driver design with the additional persistent-connection support added for this example.

## Notes / Troubleshooting

- BAS sockets are blocking by default. Outside LSP pages, wrap database work in [`ba.socket.event()`](https://realtimelogic.com/ba/doc/en/lua/auxlua.html#ba_socket_event) so the code runs in a cosocket environment.
- The OpenResty compatibility layer does not implement connection pooling. A socket added to the pool is simply closed.
- If you use WSL2, run the Mako Server there as well unless you also configure Windows-to-WSL proxying.
- The ZIP packaging command intentionally includes hidden files and directories, which is important because BAS apps depend on `.config`, `.preload`, and `.lua` resources.
- The example pages are intentionally conservative and local-first. They are there to validate driver behavior and BAS compatibility, not to provide a production database abstraction layer.
- If your own application only needs Redis or only needs MySQL, you can trim the packaged ZIP down to the parts you actually use, but keep the supporting compatibility files that the selected driver requires.
- Review the packaged module paths carefully.
