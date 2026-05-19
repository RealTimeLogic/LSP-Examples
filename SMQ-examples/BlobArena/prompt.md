# SMQ Blob Arena Prompt

Act as an expert embedded web developer and software architect specializing in Mako Server, Lua backend scripting, LSP pages, and the Simple Message Queues (SMQ) protocol.

Build a lightweight, 2D minimalist multiplayer ".io" game similar to Agar.io as a learning experiment.

## Architectural Constraints And Technical Stack

1. Backend:
   - Use Mako Server.
   - Create the app in a directory named `www`.
   - Use a custom `.preload` Lua script to initialize the SMQ broker instance.
   - `.preload` must create and expose the broker through the application table:
     - `app.smq = require"smq.hub"`
     - `app.broker = app.smq.create(...)`
   - `.preload` must define `app.dispatch`, which accepts the current LSP/request environment and attaches the request to the SMQ broker.
   - The backend broker does not subscribe to game topics. It only routes SMQ traffic between clients.

2. SMQ Entry Point:
   - Provide an LSP page named `smq.lsp`.
   - Browser clients connect to this LSP page as the SMQ WebSocket endpoint.
   - `smq.lsp` must call the dispatch function created in `.preload`, for example `app.dispatch(_ENV)`.
   - The LSP page should not contain game logic.

3. Protocol:
   - Use SMQ over WebSockets.
   - Use publish/subscribe for replicated player state.
   - Use one-to-one SMQ messaging for direct player events.
   - Periodic custom player state must be published to `/game/state`.
   - Clients subscribe to `/game/state` to maintain local mirrors of other players.
   - Do not publish custom player state to `/game/all`.

4. One-To-One Messaging:
   - When Client B receives Client A's state message on `/game/state`, Client B discovers Client A's ephemeral sender address/PTID from the SMQ message metadata.
   - Client B calls `smq.observe` for Client A's ephemeral ID so it can remove Client A from local state when Client A disconnects.
   - If Client B detects that it overlaps Client A and is large enough to consume Client A, Client B sends a direct one-to-one SMQ JSON message to Client A's discovered address.
   - Use the subtopic `eaten` for direct eaten messages.
   - The direct message should include the eater's SMQ sender address and local player name.

5. Frontend:
   - Create a monolithic single-file HTML5 client named `index.html`.
   - Use Vanilla JavaScript and HTML5 Canvas.
   - Use the official browser-based SMQ client library, normally loaded as `/rtl/smq.js`.
   - Do not use React, Vue, or any other frontend framework.

## Game Mechanics To Implement

- Players control a colored circle/blob in a bounded 2D arena.
- Use an arena size of about `1800 x 1200`, small enough that local multiplayer testing is practical.
- Use a visible grid around `48px` per cell.
- Movement must support:
  - mouse pointer destination control, and
  - arrow/WASD keyboard control.
- Each client periodically publishes its local custom player state to `/game/state`.
- Player state should include:
  - `x`
  - `y`
  - `radius`
  - `color`
  - `score`
  - `name`
  - `timestamp`
  - sequence number
  - respawn flag
- Clients maintain a map of opposing players keyed by discovered SMQ sender address/PTID.
- Remote players should be rendered smoothly using interpolation or another lightweight smoothing strategy.
- Add small colored food dots throughout the arena so players can grow before eating opponents.
- Food can be client-side/local for this educational prototype.
- Eating food increases score and grows the local blob.
- A player can consume another player only when:
  - the two circles overlap, and
  - the consuming player's radius is larger than the target player's radius.
- Fresh players start at equal size, so a fresh player should not immediately be able to eat another fresh player.
- Edible opponents should be visually marked, for example with a green ring.
- Include a small minimap in the lower-right corner:
  - show the local player,
  - show opponents,
  - color opponents green when edible,
  - color opponents orange when not currently edible.
- Upon receiving a direct `eaten` message, the targeted client:
  - resets its blob size and score,
  - moves to a new spawn position,
  - temporarily enters a respawn state,
  - displays a short respawn overlay or status message.

## Expected Files

Create a minimal runnable Mako application containing:

- `www/.preload`
  - Creates the SMQ broker.
  - Defines `app.dispatch`.
  - Performs cleanup in `onunload` by shutting down the broker.

- `www/smq.lsp`
  - Calls `app.dispatch`.
  - Acts only as the SMQ endpoint.

- `www/index.html`
  - Implements the Canvas game.
  - Connects to `smq.lsp` through SMQ.js.
  - Publishes local state to `/game/state`.
  - Subscribes to `/game/state`.
  - Uses `smq.observe` for peer disconnect cleanup.
  - Sends and receives direct one-to-one `eaten` messages.
  - Renders food, grid, players, HUD, minimap, and respawn overlay.

- `instructions.md`
  - Explains how to run the game.
  - Explains controls, food, growth, eating, minimap colors, and prototype limitations.

## Implementation Notes

- Prefer simple, readable code over a complex game engine.
- Keep collision handling and eating decisions client-side for this learning demo.
- Include comments where the SMQ-specific flow is non-obvious.
- Use the documented SMQ JavaScript APIs:
  - `SMQ.Client(SMQ.wsURL("/smq.lsp"), { cleanstart: true })`
  - `smq.pubjson(value, topic, subtopic)`
  - `smq.subscribe(topic, subtopic, settings)`
  - `smq.subscribe(topic, settings)`
  - `smq.gettid()`
  - `smq.observe(topic, onchange)`
- Use the documented Lua broker API:
  - `require"smq.hub".create(...)`
  - `smq:connect(request)`
  - `smq:shutdown(...)`
- Test after creating by running:

```powershell
mako -l::www
```

- Confirm the browser can load `http://127.0.0.1/`, render the Canvas game, and connect to SMQ.
- The goal is a working educational prototype, not a cheat-proof authoritative multiplayer server.
