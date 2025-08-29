# RESTful Services in Lua

This directory contains the example source code for the tutorial [Designing RESTful Services in Lua](https://realtimelogic.com/articles/Designing-RESTful-Services-in-Lua), which shows how to implement a RESTful API using the [Barracuda Application Server](https://realtimelogic.com/products/barracuda-application-server/) library.

---

## 🛠️ Running the example code

Run the example, using the Mako Server, as follows:

```
cd LSP-Examples/REST
mako -l::www
```

## Testing the Service

A Python script is included to test the RESTful API implementation. Before running the script, ensure that the server is listening on **port 80** (on Linux run: sudo ./restservice).

To run the test:

```bash
python TestApi.py
```

---

## 📂 File Overview

| File Path             | Description                    |
|-----------------------|--------------------------------|
| `www/.lua/rest.lua`   | The [RESTful service Lua module](REST-API.md) |
| `www/.preload`        | The RESTful example code       |

