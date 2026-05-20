# Blob Arena Multiplayer Game

## Overview

SMQ Blob Arena is a lightweight multiplayer browser game built with JavaScript, HTML5 Canvas, Lua Server Pages (LSP), and the SMQ publish/subscribe protocol included with the Mako Server.

The introductory article describing the game architecture and design is available here:

- https://makoserver.net/articles/Blob-Arena-Multiplayer-Game

## Running the Game

Start the game from the `SMQ-examples/BlobArena` directory:

```bash
mako -l::www
```

Once the server is running, open your browser and navigate to the local Mako Server instance.

## AI Prompt

The following file contains the prompt used to generate the game:

- [The prompt used to generate the game](prompt.md)

## Using an AI Agent

To execute the prompt and work with this project, you need to install an AI agent on your computer, such as:

- Codex
- Anthropic Claude
- Gemini
- Other compatible AI coding agents

The AI agent should also be able to run the Mako Server and verify that the game works correctly.

### Setup Steps

1. Install an AI agent such as Codex, Claude, or Gemini.
2. Download and [install the Mako Server](https://makoserver.net/documentation/getting-started/#install).
   
   > The installation step is important. The AI agent must be able to locate the `mako` executable from the command line.
3. Create a work directory and copy [AGENTS.md](../../AGENTS.md) to this directory.
4. Copy and paste the prompt into the AI agent.
5. Let the AI agent generate, run, and test the game locally.

