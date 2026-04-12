# RESTful Services in Lua

## Overview

This directory contains the example source code for the tutorial [Designing RESTful Services in Lua](https://realtimelogic.com/articles/Designing-RESTful-Services-in-Lua). The example implements a small in-memory user API on top of a reusable Lua router module.

## Files

- `www/.lua/rest.lua` - Reusable REST-style router module. See also [REST-API.md](REST-API.md).
- `www/.preload` - Example application that mounts the router under `/api` and defines the user endpoints.
- `TestApi.py` - Simple client script that exercises the example API.

## How to run

Start the example with the Mako Server:

```bash
cd LSP-Examples/REST
mako -l::www
```

To test the API with the included Python script, make sure the server is reachable on port `80`. On Linux, one way is:

```bash
sudo mako -u "$(whoami)" -l::www
python TestApi.py
```

## How it works

The router module in `www/.lua/rest.lua` lets you register exact and wildcard routes by HTTP method, then installs those routes into the BAS virtual file system as a directory function.

The example app in `www/.preload` mounts the router under `/api` and defines these endpoints:

- `GET /api/users`
- `POST /api/users`
- `GET /api/users/{id}`
- `PUT /api/users/{id}`
- `DELETE /api/users/{id}`

The example keeps the user records in memory, validates the submitted JSON, and returns JSON responses with appropriate HTTP status codes. `TestApi.py` then creates, queries, updates, and deletes users against that API.

## Notes / Troubleshooting

- The example uses in-memory storage only. Restarting the app resets the user list.
- The Python test script assumes `http://localhost/api/users`, so make sure the server is listening on the port the script expects.
