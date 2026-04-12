# Lua Modules, Tools, and Examples

## Overview

This repository contains ready-to-use Lua modules, tools, Lua scripts, and Lua Server Pages (LSP) examples that can be dropped directly into real applications or used as practical reference material. The examples cover common web and device use cases for the [Barracuda App Server](https://realtimelogic.com/products/barracuda-application-server/), [Mako Server](https://makoserver.net/), and [Xedge](https://realtimelogic.com/products/xedge/) product family, including forms, REST services, AJAX and WebSocket interaction, authentication, databases, IoT messaging, and embedded-device workflows.

If you are new to Lua, start with the [online Lua tutorial](https://tutorial.realtimelogic.com/).

## Files

- [AGENTS.md](AGENTS.md) - Guidance for AI-assisted work in this repository.
- [Basic HTML form](html-form) - Source code for the tutorial [HTML Forms and LSP for Beginners](https://makoserver.net/articles/HTML-Forms-and-LSP-for-Beginners).
- [Authentication: General](authentication) - Introduction to the Barracuda App Server authentication mechanism.
- [Authentication and Authorization](JSON-File-Server) - Use of the [JSON Authenticator](https://realtimelogic.com/ba/doc/en/lua/lua.html#ba_create_jsonuser) with a file server.
- [Authentication: OAuth 2.0](oauth) - Example showing GitHub OAuth 2.0 access.
- [Authentication: WebAuthn](WebAuthn) - Passwordless, FIDO2-compliant authentication examples.
- [Authentication: Single Sign On](fs-sso) - Single Sign-On example designed to avoid pre-installed password vulnerabilities.
- [Authentication: RADIUS](RADIUS) - RADIUS integration for BAS authentication.
- [AJAX / REST: For Beginners](AJAX)
- [AJAX / REST / RPC Over WebSockets](AJAX-Over-WebSockets)
- [htmx Examples](htmx) - htmx + LSP examples for server-rendered interactive pages.
- [Website Template Engine for Embedded](Light-Dashboard) - Embedded dashboard templates with optional TPM-backed user database support.
- [Dynamic Navigation Menu](Dynamic-Nav-Menu)
- [Debug Lua](Lua-Debug) - Visual Studio Code debugging workflow for Lua and LSP.
- [Email + Logging](Email-and-Logging) - Sending email directly and through the Mako logging system.
- [GitHub IO](GitHubIo) - GitHub repository presented as a BAS file system.
- [IoT: SMQ Examples](SMQ-examples) - Device-management and messaging examples built on [SMQ](https://realtimelogic.com/ba/doc/?url=SMQ.html).
- [IoT: MQTT and AWS](AWS-MQTT) - AWS IoT Core connection example.
- [IoT: MQTT Sparkplug](Sparkplug) - Sparkplug library notes and example applications.
- [RESTful](REST) - Designing RESTful services in Lua.
- [ESP32 Microcontroller Examples](ESP32) - Examples designed for [Xedge32](https://realtimelogic.com/downloads/bas/ESP32/).
- [MinnowSim](MinnowSim) - Source code for the tutorial [Your First Embedded Single Page Application](https://realtimelogic.com/articles/Your-First-Embedded-Single-Page-Application).
- [MyApp.zip](MyApp.zip) - Ready-to-run example for [Mastering Xedge Application Deployment: From Installation to Creation](https://realtimelogic.com/articles/Mastering-Xedge-Application-Deployment-From-Installation-to-Creation).
- [SQL: SQLite Examples](SQLite)
- [SQL: MySQL and Redis Examples](MysqlAndRedis)
- [SQL: PostgreSQL Example](PostgreSQL)
- [File Upload, including drag and drop](upload)
- [WebDAV and Web File Server](File-Server)
- [CryptoIO - AES-GCM file encryption](CryptoIO)
- [How to add `require` search paths to an app](require-test)
- [Sockets and WebSockets examples](socket-examples)
- [Web Shell](Web-Shell)
- [The ephemeral request/response environment](command-env)
- [CGI Plugin and Examples](CGI) - CGI compatibility layer implemented in Lua.
- [QNX: PPS to SMQ Bridge](QNX/PPS) - Extension example for QNX Persistent Publish Subscribe.

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
