# Lua Modules, Tools, and Examples

## Overview

This repository contains ready-to-use Lua modules, tools, Lua scripts, and Lua Server Pages (LSP) examples that can be dropped directly into real applications or used as practical reference material. The examples cover common web and device use cases for the [Barracuda App Server](https://realtimelogic.com/products/barracuda-application-server/), [Mako Server](https://makoserver.net/), and [Xedge](https://realtimelogic.com/products/xedge/) product family, including forms, REST services, AJAX and WebSocket interaction, authentication, databases, IoT messaging, and embedded-device workflows.

If you are new to Lua, start with the [online Lua tutorial](https://tutorial.realtimelogic.com/).

## AI-assisted development

The root [AGENTS.md](AGENTS.md) teaches an AI agent how to work correctly with
BAS, Mako Server, Xedge, Xedge32, LSP, routing, authentication, SQLite, SMQ,
and browser interfaces. Prepared examples also include local `AGENTS.md` files
with more specific instructions.

### Start a new project

Copy [AGENTS.md](AGENTS.md) into the root of the new working directory and keep
the filename unchanged. Start the AI agent in that directory and use this
bootstrap prompt:

```text
Read and follow AGENTS.md. Complete its mandatory reference bootstrap before
doing any work. If downloading is blocked, request the required permissions; if
that fails, give me the exact download links and destination paths.

Then inspect this workspace and tell me what you found. Do not change any
application files until you have confirmed the target runtime, application
root, and relevant example or architecture with me.
```

The agent downloads the required API references and skills into
`.agents/reference/rtl/`, then uses them as the source of truth for the work.
For an offline project, copy the complete reference directory together with
`AGENTS.md`.

### Develop on a running system with LSP-Claw

[LSP-Claw](https://github.com/RealTimeLogic/LSP-Claw) is an MCP server that lets
an AI agent inspect examples, create files, run a controlled lab app, and debug
Lua/LSP code directly on Mako Server, Xedge, or Xedge32. Use it when the agent
should select an example, build and test the application, and inspect runtime
trace output without modifying production code first.

On embedded systems, LSP-Claw can restart or replace only the lab application
without restarting the device, RTOS, or hosting server.

## Files

- [Basic HTML form](html-form) - Source code for the tutorial [HTML Forms and LSP for Beginners](https://makoserver.net/articles/HTML-Forms-and-LSP-for-Beginners).
- [Anti-Session](anti-session) - Shows how to carry a browser state through multiple pages without using a server session.
- Authentication
  - [Authentication and Authorization](JSON-File-Server) - Use of the [JSON Authenticator](https://realtimelogic.com/ba/doc/en/lua/lua.html#ba_create_jsonuser) with a file server.
  - [General](authentication) - Introduction to the Barracuda App Server authentication mechanism.
  - [OAuth 2.0](oauth) - Example showing GitHub OAuth 2.0 access.
  - [RADIUS](RADIUS) - RADIUS integration for BAS authentication.
  - [Single Sign On](fs-sso) - Single Sign-On example designed to avoid pre-installed password vulnerabilities.
  - [WebAuthn](WebAuthn) - Passwordless, FIDO2-compliant authentication examples.
- [CGI Plugin and Examples](CGI) - CGI compatibility layer implemented in Lua.
- [CryptoIO - AES-GCM file encryption](CryptoIO)
- [Debug Lua](Lua-Debug) - Visual Studio Code debugging workflow for Lua and LSP.
- [Dynamic Navigation Menu](Dynamic-Nav-Menu)
- [Email + Logging](Email-and-Logging) - Sending email directly and through the Mako logging system.
- [File Upload, including drag and drop](upload)
- [GitHub IO](GitHubIo) - GitHub repository presented as a BAS file system.
- [How to add `require` search paths to an app](require-test)
- [htmx Examples](htmx) - htmx + LSP examples for server-rendered interactive pages.
- IoT
  - [ESP32 Microcontroller Examples](ESP32) - Examples designed for [Xedge32](https://realtimelogic.com/downloads/bas/ESP32/).
  - [MQTT and AWS](AWS-MQTT) - AWS IoT Core connection example.
  - [MQTT Broker](MQTT-Broker) - A ready-to-use **MQTT broker** and example code.
  - [MQTT Sparkplug](Sparkplug) - Sparkplug library notes and example applications.
  - [SMQ Examples](SMQ-examples) - Device-management and messaging examples built on [SMQ](https://realtimelogic.com/ba/doc/?url=SMQ.html).
- [MinnowSim](MinnowSim) - Source code for the tutorial [Your First Embedded Single Page Application](https://realtimelogic.com/articles/Your-First-Embedded-Single-Page-Application).
- [QNX: PPS to SMQ Bridge](QNX/PPS) - Extension example for QNX Persistent Publish Subscribe.
- REST / AJAX / RPC - different names, same idea
  - [AJAX / REST / RPC Over WebSockets](AJAX-Over-WebSockets)
  - [AJAX / REST: For Beginners](AJAX)
  - [RESTful](REST) - Designing RESTful services in Lua.
- [Sockets and WebSockets examples](socket-examples)
- SQL
  - [MySQL and Redis Examples](MysqlAndRedis)
  - [PostgreSQL Example](PostgreSQL)
  - [SQLite Examples](SQLite)
- [The ephemeral request/response environment](command-env)
- [Web Shell](Web-Shell)
- [WebDAV and Web File Server](File-Server)
- [Website Template Engine for Embedded](Light-Dashboard) - Embedded dashboard templates with optional TPM-backed user database support.
- [Xedge App Deployment](Xedge-App-Deployment) - Source layout for packaging `MyApp.zip` for [Mastering Xedge Application Deployment: From Installation to Creation](https://realtimelogic.com/articles/Mastering-Xedge-Application-Deployment-From-Installation-to-Creation).

## How to run

There is no single startup command for the repository as a whole. Open the README in the specific subdirectory you want to explore and run that example from its own directory.

## How it works

Each subdirectory is a mostly self-contained example application, module, or tutorial companion. Some entries are ready-to-run Mako apps, some are reusable Lua modules, and some are index pages that point you to a smaller example beneath them.

## Notes / Troubleshooting

Most of the examples include hidden files or directories such as `.preload`, `.config`, or `.lua`. In BAS products, resources whose names start with a dot are hidden from HTTP clients and are intended for server-side use only. On Linux, use:

```bash
ls -a
```

to make sure you see the complete example structure.
