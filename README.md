# LSP-Examples
 [Lua and LSP](https://realtimelogic.com/products/lua-server-pages/) examples, including IoT/Cloud connectivity. New to Lua? Check out the [online Lua tutorial](https://tutorial.realtimelogic.com/).


* [Basic HTML form](html-form) - Source code for the tutorial [HTML Forms and LSP for Beginners](https://makoserver.net/articles/HTML-Forms-and-LSP-for-Beginners).
* [Authentication: General](authentication) - Introduction to the Barracuda App Server's authentication mechanism
* [Authentication and Authorization](JSON-File-Server) - Shows how to use the **[JSON Authenticator](https://realtimelogic.com/ba/doc/en/lua/lua.html#ba_create_jsonuser)** with a File Server
* [Authentication: OAuth 2.0](oauth) - Shows how to access GitHub using OAuth 2.0
* [Authentication: WebAuthn](WebAuthn) - Passwordless, FIDO2-compliant security with public-key cryptography
* [Authentication: Single Sign On](fs-sso) - Prevent Pre-Installed Password Vulnerabilities with Single Sign-On
* [Authentication: RADIUS](RADIUS) - Remote Authentication Dial-In User Service Lua authentication integration
* [AJAX: For Beginners](AJAX)
* [AJAX: Over WebSockets](AJAX-Over-WebSockets)
* [htmx Examples](htmx) - htmx lets you update web pages with server-rendered HTML, making it the perfect match for LSP's lightweight, dynamic backend.
* [Website Template Engine for Embedded](Light-Dashboard) - Fast track your web app design with this engine. Includes TPM-protected user database.
* [Dynamic Navigation Menu](Dynamic-Nav-Menu)
* [Debug Lua](Lua-Debug) - How to Debug Lua Code Using Visual Studio Code
* [GitHub IO](GitHubIo) - How to make a GitHub repository look and behave like a file system
* [IoT: SMQ Examples](SMQ-examples) - Easy and secure device management using [SMQ](https://realtimelogic.com/ba/doc/?url=SMQ.html)
* [IoT: MQTT and AWS](AWS-MQTT) - How to Connect to AWS IoT Core using MQTT & ALPN
* [IoT: MQTT Sparkplug](Sparkplug) - How to use the MQTT Sparkplug library
* [RESTful](REST) - Designing RESTful Services in Lua
* [ESP32 Microcontroller Examples](ESP32) - Examples designed for [Xedge32](https://realtimelogic.com/downloads/bas/ESP32/)
* [MinnowSim](MinnowSim) - Source code for the tutorial [Your First Embedded Single Page Application](https://realtimelogic.com/articles/Your-First-Embedded-Single-Page-Application)
* [MyApp.zip](MyApp.zip) - Ready to run example designed for the tutorial [Mastering Xedge Application Deployment: From Installation to Creation](https://realtimelogic.com/articles/Mastering-Xedge-Application-Deployment-From-Installation-to-Creation)
* [SQL: SQLite Examples](SQLite) - Database examples
* [SQL: MySQL and Redis Examples](MysqlAndRedis) - Database examples
* [SQL: PostgreSQL Example](PostgreSQL) - Database example
* [File Upload, including drag and drop](upload) - HTML based file upload
* [WebDAV and Web-File-Server](File-Server) - Network drive and secure file sharing
* [How to add 'require' search path to an app](require-test)
* [Sockets and webSockets examples](socket-examples)
* [Web Shell](Web-Shell) - web based alternative to SSH
* [The ephemeral request/response environment](command-env) - using response:include() and response:forward()
* [CGI Plugin and Examples](CGI) - For old apps using [Common Gateway Interface](https://realtimelogic.com/articles/Barracuda-Server-versus-CGI)
* [QNX: PPS to SMQ Bridge](QNX/PPS) -  How to extend QNX Persistent Publish Subscribe

## Linux Users

Most of the examples include hidden files and/or directories. With the
Barracuda App Server, resources starting with a dot are hidden and
cannot be accessed by an HTTP client such as a browser. The resources
can only be accessed on the server side. To make sure you see all
resources, use the Linux command: ls -a
