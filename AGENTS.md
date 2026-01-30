# AGENTS.md – Barracuda App Server (Generic)

## Purpose
This document provides **generic guidance for working with the Barracuda App Server (BAS)** and its derivatives, such as Mako Server and Xedge, using AI-assisted development. It is **not tied to any specific application, UI template, or example project**.

The goal is to help an AI (or developer) understand how to:
- Navigate the Barracuda App Server architecture
- Use the official Lua, LSP, JavaScript, and C/C++ APIs correctly
- Generate correct server-side and client-side code
- Rely on the official documentation as the source of truth

---

## AI usage guidelines

- This project has been validated with **Codex**, but other AI engines should also work.
- Always point the AI to **this file (AGENTS.md)** when asking it to generate or modify code.
- Explicitly state whether the task concerns:
  - Server-side Lua
  - Lua Server Pages (LSP)
  - Client-side JavaScript
  - SMQ messaging
  - C or C++ integration

The AI **must not invent APIs**. If something is unclear, the AI should consult the official documentation listed below.

---

## Official documentation (source of truth)

### Core Barracuda App Server APIs

- **Lua & Lua Server Pages (LSP)**  
  https://realtimelogic.com/ba/doc/en/lua/lua.html

- **Auxiliary Lua APIs** (HTTP client, sockets, ByteArray, UBJSON, CBOR, etc.)  
  https://realtimelogic.com/ba/doc/en/lua/auxlua.html

### Protocols

- SMQ JS client API: https://realtimelogic.com/ba/doc/en/JavaScript/SMQ.html
- SMQ broker API: https://realtimelogic.com/ba/doc/en/lua/SMQ.html
- MQTT API: https://realtimelogic.com/ba/doc/en/lua/MQTT.html
- Modbus API: https://realtimelogic.com/ba/doc/en/lua/Modbus.html
- OPC UA API (index): https://realtimelogic.com/ba/opcua/index.html

> Note: These pages cover the most commonly used APIs. The Barracuda App Server exposes **many additional APIs** that are not all linked from a single page.

---

## Documentation index (critical)

For a **complete and correct understanding** of the Barracuda App Server, the documentation index **must be followed systematically**.

This index covers **both Lua and C/C++ APIs**:

https://realtimelogic.com/ba/indexbuilder.lsp

> ⚠️ Important:
> - The documentation is structured hierarchically.
> - Skipping the index often leads to misunderstandings about available APIs and runtime behavior.
> - AI-generated code should assume the index has been reviewed.

---

## SMQ (Simple Message Queue)

SMQ is the built-in publish/subscribe messaging system used by the Barracuda App Server.

### Official SMQ documentation

- **SMQ JavaScript API (client-side)**  
  https://realtimelogic.com/ba/doc/en/JavaScript/SMQ.html

- **SMQ Lua API (server-side broker and publishers)**  
  https://realtimelogic.com/ba/doc/en/lua/SMQ.html

### SMQ publish signatures (Lua)

- **Broadcast publish**
  ```lua
  smq:publish(data, "topic")
  ```

- **Direct publish (point-to-point)**
  ```lua
  smq:publish(data, ptid, "topic")
  ```

The AI should always follow these exact signatures.

---

## Client–server responsibilities

When generating code, the AI must clearly separate responsibilities:

### Server-side (Lua / C / C++)
- Owns data sources (sensors, state, hardware, logic)
- Publishes data via SMQ or exposes REST/HTTP endpoints
- Enforces authentication, authorization, and security headers

### Client-side (JavaScript)
- Subscribes to SMQ topics
- Renders UI updates
- Never embeds server secrets or credentials

---

## Security considerations

- Follow the **principle of least privilege** when exposing endpoints
- Update Content Security Policy (CSP) headers when adding external scripts or styles
- Treat authentication, TLS, and trust management as first-class design concerns

The Barracuda App Server provides built-in primitives for these tasks; external frameworks are typically unnecessary.

---

## Guidance for AI-generated code

When asking an AI to generate code:

- Always reference the **official documentation URLs above**
- Specify whether the code targets:
  - Embedded RTOS environments
  - Embedded Linux
  - Desktop or server-class systems
- Prefer **Barracuda App Server native APIs** over third-party libraries
- Avoid assumptions based on generic Lua, OpenResty, or browser frameworks; If uncertain or if the required API cannot be found, ask for clarification before generating any code

---

## Final note

This AGENTS.md file is intentionally **generic and reusable**.

It applies to:
- Embedded web servers
- Edge devices
- Industrial products
- Secure IoT gateways

Any application-specific structure, UI framework, or project layout must be documented **separately**, and the AI must ask for this documentation, if needed.

