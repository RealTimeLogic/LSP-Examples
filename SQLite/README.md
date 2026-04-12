# SQLite Examples

## Overview

This directory is the landing page for the SQLite-related examples in the repository. It is intended as an index so you can choose the example that best matches what you want to learn first.

## Files

- [Lua SQLite Database Tutorial](Tutorial) - Recommended starting point.
- [Basic Wiki Engine](Wiki) - URL-to-database mapping example.
- [SQLite Shared Connection Example](Shared-Connection) - Preferred connection-management example for web-server scenarios.

## How to run

Open the README in the specific subdirectory you want to run. Each SQLite example starts as its own Mako Server app.

## How it works

Each subdirectory demonstrates a different SQLite usage pattern: basic form-driven CRUD, URL-based content mapping, or shared-connection behavior under server request load.

## Notes / Troubleshooting

- Start with `Tutorial/` if you are new to SQLite on BAS.
- Move to `Shared-Connection/` if your main question is connection management and locking behavior.
