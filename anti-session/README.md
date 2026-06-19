# Anti-Session Encrypted Form State

## Purpose

This example shows how to carry a browser state through a multi-page form flow without using the server-side session object.

The browser stores an encrypted JSON object in a hidden form field. The server decrypts the object on each POST, updates it, encrypts it again, and sends it back in the next form.

This pattern can be useful for simple embedded user interfaces where you want a short multi-step workflow but do not want to allocate server-side session state for every browser.

## What This Example Shows

- `ba.aesencode` encrypts a JSON state object before it is sent to the browser.
- `ba.aesdecode` decrypts the state object when the form is posted back.
- The browser carries the encrypted state, but does not need to understand it.
- The server remains stateless for this workflow.

The example collects:

1. The server time when the workflow started
2. The user's name
3. The user's favorite food

The final page decrypts the submitted state and displays the collected values.

## How To Run

Start the example with Mako Server:

```powershell
cd anti-session
mako -l::www
```

Then open the printed HTTP URL in a browser.

## File Structure

```text
anti-session/
  README.md
  www/
    .preload       # AES key and helper functions
    index.lsp      # Start page, creates encrypted state
    name.lsp       # Adds the user's name
    food.lsp       # Adds the user's favorite food
    summary.lsp    # Displays the decrypted summary
    header.shtml   # Shared page header
    footer.shtml   # Shared page footer
    style.css      # Shared dark technical theme
```

Each LSP page uses:

```lua
response:include"header.shtml"
-- page content
response:include"footer.shtml"
```

This keeps the pages small and makes the layout easy to update.

## How The Flow Works

### 1. `index.lsp` creates encrypted state

The page creates a Lua table with the current time:

```lua
{ started = ba.datetime"NOW":tostring() }
```

The helper in `.preload` converts the table to JSON and encrypts it:

```lua
ba.aesencode(secret, ba.json.encode(state))
```

The encrypted value is stored in a hidden form field named `state`.

### 2. `name.lsp` asks for the user's name

The encrypted state is posted from `index.lsp` to `name.lsp`. The page asks for the user's name and posts both values to `food.lsp`.

### 3. `food.lsp` updates and re-encrypts state

`food.lsp` decrypts the state, adds the submitted name, encrypts the updated JSON object, and asks for the user's favorite food.

### 4. `summary.lsp` shows the collected data

`summary.lsp` decrypts the state, adds the submitted food, and displays the full data set.

## Why This Is Not A Session

With a server-side session object, the server keeps per-browser state and the browser sends only a session identifier.

In this example, the browser carries the full workflow state, but the state is encrypted and decoded only by the server. The server does not need a session table for this workflow.

## Limitations

- Keep the encrypted object small. Hidden form fields are not a database.
- This pattern is not a replacement for authentication or authorization.
- If the server restarts, the AES key changes and existing encrypted form state can no longer be decoded.
- The example does not include expiry enforcement, but the stored timestamp shows where such a check can be added.

## BAS API References

- [`ba.aeskey`](https://realtimelogic.com/ba/doc/?url=lua/lua.html#ba_aeskey)
- [`ba.aesencode`](https://realtimelogic.com/ba/doc/?url=lua/lua.html#ba_aesencode)
- [`ba.aesdecode`](https://realtimelogic.com/ba/doc/?url=lua/lua.html#ba_aesdecode)
- [`ba.json.encode`](https://realtimelogic.com/ba/doc/?url=lua/lua.html#json_encode)
- [`ba.json.decode`](https://realtimelogic.com/ba/doc/?url=lua/lua.html#json_decode)
- [`ba.datetime`](https://realtimelogic.com/ba/doc/?url=lua/lua.html#ba_datetime)
