# Blob Arena Multiplayer Game

## Overview

SMQ Blob Arena is a lightweight multiplayer browser game built with JavaScript, HTML5 Canvas, Lua Server Pages (LSP), and the SMQ publish/subscribe protocol included with the Mako Server.

This repository includes two AI-generated versions of the same game prompt:

- `codex` - generated with Codex
- `gemini` - generated with Gemini

The two versions demonstrate how AI agents can create similar, but not identical, applications from the same prompt.

### Tutorial

The introductory article describing the game architecture and design is available here:

- https://makoserver.net/articles/Blob-Arena-Multiplayer-Game

## Running the Game using Mako Server and Xedge

Start either game from the `SMQ-examples/BlobArena` directory.

To run the Codex version:

```bash
cd SMQ-examples/BlobArena
mako -l::codex
```

To run the Gemini version:

```bash
cd SMQ-examples/BlobArena
mako -l::gemini
```

After the server starts, open the HTTP URL printed in the Mako console. Open the game in two browser windows to confirm that multiplayer state is shared through SMQ.

## Packaging for Xedge

Package one Blob Arena variant at a time. Create the ZIP from inside the selected variant directory so `.config`, `.preload`, `index.html`, and `smq.lsp` are at the ZIP root. See [Xedge App Deployment](../../Xedge-App-Deployment/README.md) for the detailed deployment workflow.

```bash
cd codex
zip -D -q -u -r -9 ../blobarena-codex.zip .
```

```bash
cd gemini
zip -D -q -u -r -9 ../blobarena-gemini.zip .
```

Upload the generated ZIP with the Xedge App Upload tool.


## AI Prompt

The following file contains the prompt used to generate the game:

- [The prompt used to generate the game](prompt.md)

## Using an AI-Agent

To execute the prompt and work with this project, you need to install an AI-agent on your computer, such as:

- Codex
- Anthropic Claude
- Gemini
- Other compatible AI coding agents

The AI-agent should also be able to run the Mako Server and verify that the game works correctly.

### Setup Steps

1. Install an AI-agent such as Codex, Claude, or Gemini.
2. Download and [install the Mako Server](https://makoserver.net/documentation/getting-started/#install).
   
   > The installation step is important. The AI-agent must be able to locate the `mako` executable from the command line.
3. Create a work directory and copy [AGENTS.md](../../AGENTS.md) to this directory.
4. Copy and paste the prompt into the AI-agent.
5. Let the AI-agent generate, run, and test the game locally.

The reason you want to [install the Mako Server](https://makoserver.net/documentation/getting-started/#install) so the agent can find it is that AI-agents can do much more than simply generate code. It can also run the Mako Server, monitor the server console for Lua errors, automatically fix source code issues, and restart the application as needed.

The agent can then open the game in a browser, navigate the application, and verify that it behaves correctly. If something fails, such as a Lua runtime error, broken UI logic, or unexpected game behavior, the agent can continue modifying and testing the code until the application works as intended.

This creates an iterative development loop in which the AI-agent assists with coding, debugging, testing, and validation, significantly speeding up development and reducing manual trial-and-error.


## The AGENTS Markdown File

For more information on AGENTS.md, see the official page: [https://agents.md/](https://agents.md/).
