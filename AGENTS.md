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

The AI **must not invent APIs**. If something is unclear, the AI should consult the consolidated BAS documentation and tutorials listed below.

---

## Official documentation (source of truth)

Use these consolidated files as the primary references:

- **BAS documentation bundle (`basapi.md`)**  
  http://realtimelogic.com/downloads/basapi.md

- **BAS tutorials bundle (`tutorials.md`)**  
  http://realtimelogic.com/downloads/tutorials.md

- **Mako Server tutorials bundle (`tutorials.md`)**  
  https://makoserver.net/download/tutorials.md

### Protocols

- SMQ JS client API: http://realtimelogic.com/downloads/basapi.md
- SMQ broker API: http://realtimelogic.com/downloads/basapi.md
- MQTT API: http://realtimelogic.com/downloads/basapi.md
- Modbus API: http://realtimelogic.com/downloads/basapi.md
- OPC UA API (index): http://realtimelogic.com/downloads/basapi.md

> Reference priority:
> 1. `basapi.md` for API syntax, signatures, and behavior (source of truth)
> 2. `tutorials.md` for architecture, patterns, examples, and security guidance
> 3. If guidance conflicts with API details, trust `basapi.md`

## SMQ (Simple Message Queue)

SMQ is the built-in publish/subscribe messaging system used by the Barracuda App Server.

### Official SMQ documentation

- **SMQ JavaScript API (client-side)**  
  http://realtimelogic.com/downloads/basapi.md

- **SMQ Lua API (server-side broker and publishers)**  
  http://realtimelogic.com/downloads/basapi.md

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

- Always reference `http://realtimelogic.com/downloads/basapi.md`
- For architecture/security/best-practice questions, also reference `http://realtimelogic.com/downloads/tutorials.md`
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
