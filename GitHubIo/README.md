## GitHub IO

**GitHub IO** is a [LuaIo-compatible filesystem driver](https://realtimelogic.com/ba/doc/en/lua/auxlua.html#luaio) that makes a GitHub repository look and behave like a file system inside the Barracuda App Server (BAS).

![GitHub IO](https://realtimelogic.com/images/GitHubIO.jpg "GitHub IO")

Instead of reading and writing from local disk, all file operations are translated into GitHub REST API calls:

- **Read files** → fetched via the GitHub "raw" API
- **Write/update files** → uploaded with PUT /contents/{path}
- **Delete files and directories** → handled with DELETE /contents/{path}, with recursive directory removal
- **List directories** → mapped to GitHub's JSON directory listings
- **Create directories** → emulated with .keep files since Git doesn't support empty folders

In practice, this means you can mount a GitHub repo as if it were a local filesystem and use regular [BAS IO]((https://realtimelogic.com/ba/doc/en/lua/lua.html#ba_ioinfo)) calls (open, stat, files, etc.) to manage content, while under the hood, everything is **versioned and committed** to GitHub.

In addition to calling the Lua IO interface methods directly, the object can also be passed to any BAS component that accepts an IO interface, such as the [WebDAV server](https://realtimelogic.com/ba/doc/en/lua/lua.html#ba_create_dav). By doing so, you can expose a GitHub repository as a versioned network file system. Note that many WebDAV clients, including the one built into Windows, generate a high volume of file I/O operations, which can result in substantial traffic to GitHub. When using WebDAV, limit it to small repositories and avoid transferring large files. It is best suited for working with source code files only.

> **&#x1F449; Tip:**
> When using the **[Xedge IDE](https://realtimelogic.com/ba/doc/en/Xedge.html)**, you can integrate a GitHub-backed file system directly into the Xedge UI by calling the **[xedge.auxapp() function](https://realtimelogic.com/ba/doc/en/Xedge.html#auxapp)**.
> This allows you to mount a GitHub IO instance as an auxiliary app, making the repository appear in the IDE just like a local project. From there, you can browse, edit, and manage files while keeping them versioned in GitHub.





## Testing the GitHub IO

To test the code, first create a new empty GitHub repository and generate a fine-grained personal access token with permissions limited to that repository. Next, edit the `GitHubIo/www/.preload` file and update the initialization code with the repository owner, the repository name, and token.

When configured, run the example, using the Mako Server, as follows:

```
cd GitHubIo
mako -l::www
```

For detailed instructions on starting the Mako Server, check out our [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and review the server's [command line options](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp) in our documentation.

After starting the Mako Server, use a browser and navigate to
http://localhost/git/. You can now use the Web File Manager for uploading and downloading files. You can also mount http://localhost/git/ as a WebDAV drive.

## Source Code

- Lua module: [GitHubIo.lua](www/.lua/GitHubIo.lua)
- Example code [.preload](www/.preload)


## `create` Function

The `create` function instantiates and returns an [IO interface object](https://realtimelogic.com/ba/doc/en/lua/lua.html#ba_ioinfo) that can be used like any other BAS IO interface (e.g. `open`, `files`, `stat`, `mkdir`, `rmdir`, `remove`).

```lua
local ghio = require"GitHubIo".create{
   owner  = "RealTimeLogic",
   repo   = "GitHubIoTest",
   token  = "github_pat_xxxxx",
   branch = "main",
   log=function(url,code,message) trace(url,code,message) end,
   mtime=os.time()
}
```

* * *

## Options

### `owner` _(string, required)_

GitHub username or organization name that owns the repository.

Example:

`owner = "RealTimeLogic"`

* * *

### `repo` _(string, required)_

The name of the repository to access.

Example:

`repo = "GitHubIoTest"`

* * *

### `token` _(string, required)_

A **GitHub Personal Access Token (PAT)** with `repo` scope.

Used for authentication. Sent as a Bearer token in every request.

Example:

`token = "github_pat_xxxxx""`

* * *

### `branch` _(string, optional)_

The branch to operate on. Defaults to `"main"`.

Example:

`branch = "develop"`

* * *

### `api` _(string, optional)_

The GitHub API base URL. Defaults to `https://api.github.com`.

Use this if you are working with a **GitHub Enterprise** instance.

Example:

`api = "https://github.mycompany.com/api/v3"`


### `log` _(boolean or function, optional)_

Any GitHub error (for example, invalid credentials) causes the IO object operation to fail. The error returned by methods such as `open` may not contain useful details.

- If `log` is set to **`true`**, error messages are printed to the trace buffer.
- If `log` is set to a **function**, the function is called with three arguments:
  1. The request URL
  2. The HTTP response code
  3. The error message returned by GitHub

* * *

### `mtime` _(number, optional)_

GitHub does not provide file modification timestamps. You can normalize and assign a fixed `mtime` value to all nodes. For example:

`mtime = os.time()`



* * *

## Behavior

- **Directories**


  GitHub doesn't store empty directories. This driver simulates them by creating a `.keep` file in empty folders.

- **`mtime`**


  Always set to a normalized value (GitHub doesn't provide standard filesystem timestamps in this API).

- **Concurrency**

  Each GitHub request creates its own `httpc` client. Safe for use across multiple BAS cooperative threads.

- **Recursive Deletion**

  `rmdir` removes entire directory trees (including nested files and subdirectories).

- **File Operations**
  - `open("r")`: reads a file's raw content.

  - `open("w")`: Base64-encode the data and uploads it on `close`. The `flush` function is a no-op.
