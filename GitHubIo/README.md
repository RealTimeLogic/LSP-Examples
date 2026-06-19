# GitHub IO

## Overview

**GitHub IO** is a [LuaIO-compatible filesystem driver](https://realtimelogic.com/ba/doc/en/lua/auxlua.html#luaio) that makes a GitHub repository look and behave like a file system inside the Barracuda App Server.

![GitHub IO](https://realtimelogic.com/images/GitHubIO.jpg "GitHub IO")

Instead of reading and writing local disk files, the driver translates file operations into GitHub API calls:

- reading files uses GitHub's raw-content support
- writing files uses the repository contents API
- deleting files and directories uses the contents API, including recursive directory removal
- directory listings come from GitHub JSON directory metadata
- recursive repository listings use GitHub's tree API
- empty directories are emulated with `.keep` files because Git does not store empty folders

Because the returned object follows the BAS IO model, you can use it anywhere a BAS IO is accepted, including with the WebDAV/Web File Server. That means a GitHub repository can be exposed as a versioned network file system. Keep in mind that WebDAV clients can generate a lot of file traffic, so this pattern is best suited for small repositories and source files rather than large binary payloads.

When used from [Xedge](https://realtimelogic.com/ba/doc/en/Xedge.html), the same GitHub-backed IO can also be mounted into the IDE through [`xedge.auxapp()`](https://realtimelogic.com/ba/doc/en/Xedge.html#auxapp), which makes the repository appear like a local project inside the UI.

## Files

- `www/.lua/GitHubIo.lua` - GitHub IO driver module.
- `www/.preload` - Example startup script that creates the GitHub-backed file system and mounts it at `/git/`.

## How to run

Before running the example:

1. Create a new empty GitHub repository.
2. Generate a fine-grained personal access token limited to that repository.
3. Open `GitHubIo/www/.preload`.
4. Replace the placeholder values for:
   - repository owner
   - repository name
   - GitHub token
5. Remove the intentional `error(...)` line at the top of `.preload`.

Then start the example:

```bash
cd GitHubIo
mako -l::www
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

After the server starts, open the HTTP URL printed in the Mako console with `/git/` appended. You can then use the Web File Manager for upload and download operations, or mount the same `/git/` URL as a WebDAV drive.

## How it works

The example startup script creates the driver with:

```lua
local ghio, info = require"GitHubIo".create{
   owner  = "RealTimeLogic", -- required
   repo   = "GitHubIoTest", -- required
   token  = "github_pat_xxxxx", -- optional
   branch = "main", -- optional
   log=function(url,code,message) trace(url,code,message) end, -- optional
   mtime=os.time()  -- optional
}
```

It then creates a Web File Server on top of that IO and mounts it at `/git/`.

### `create` function

`create(...)` returns two values:

1. A BAS [IO interface object](https://realtimelogic.com/ba/doc/en/lua/lua.html#ba_ioinfo) that supports common methods such as `open`, `files`, `stat`, `mkdir`, `rmdir`, and `remove`.
2. An extended API table for GitHub-specific helper operations.

That is what makes the module practical: code written against the BAS IO abstraction can often be reused with minimal change, even though the backing storage is now GitHub instead of a local disk.

The extended API is documented at the end of this README.

### Options

#### `owner` `(string, required)`

GitHub username or organization name that owns the repository.

#### `repo` `(string, required)`

Repository name.

#### `token` `(string, optional)`

The GitHub Personal Access Token, used for authentication, is required for private repositories and write access. You do not need to set this token if you are accessing a public repository in read-only mode.


#### `branch` `(string, optional)`

Branch to operate on. Defaults to `main`.

#### `api` `(string, optional)`

GitHub API base URL. Use this for GitHub Enterprise installations.

#### `log` `(boolean or function, optional)`

Controls error reporting:

- `true` prints GitHub errors to the trace buffer
- a function receives `(url, code, message)` for each reported error

#### `mtime` `(number, optional)`

GitHub does not provide normal filesystem modification timestamps through this interface, so you can assign a normalized value to all returned nodes.

#### `lockdir` `(string, optional)`

Lock-directory name used when the IO is mounted behind WebDAV. The default is `.LOCK`.

### Behavior

- Empty directories are represented with `.keep` files.
- `open("r")` reads raw file content.
- `open("w")` buffers the data and uploads it on `close()`.
- `flush()` is effectively a no-op for write mode in this driver.
- `rmdir()` removes complete directory trees recursively.
- Each GitHub request creates its own HTTP client, which makes the driver safe for concurrent BAS cooperative threads.
- `mtime` is normalized because the GitHub contents API does not expose normal filesystem timestamps in the same way a local file system does.
- The `lockdir` value should match the WebDAV lock-directory configuration if you combine the driver with a WebDAV server.

## Packaging for Xedge

This example can be packaged as an Xedge app by creating a ZIP from the app directory, so the app files are at the ZIP root. See [Xedge App Deployment](../Xedge-App-Deployment/README.md) for the detailed deployment workflow.

```bash
cd www
zip -D -q -u -r -9 ../GitHubIo.zip .
```

Upload the generated ZIP with the Xedge App Upload tool.


## Notes / Troubleshooting

- The shipped `.preload` intentionally stops with an error until you edit it. That prevents accidental use with placeholder credentials.
- If you use this driver with WebDAV, keep the repository small and expect a higher GitHub API call volume than with direct browser editing.
- In Xedge, the same driver can also be integrated into the IDE through [`xedge.auxapp()`](https://realtimelogic.com/ba/doc/en/Xedge.html#auxapp).
- For routine testing, start with a new empty repository so you can clearly see how file operations map to Git commits and repository contents.

## Extended API

The second return value from `create(...)` exposes GitHub-specific helpers for operations that are inefficient, inconvenient, or outside the normal LuaIo model:

```lua
local ghio, info = require"GitHubIo".create{
   owner  = "RealTimeLogic",
   repo   = "GitHubIoTest",
   branch = "main",
   token  = "github_pat_xxxxx",
}

local files, err = info.files()
```

Most extended helpers return `value, err, meta`. `meta` contains response metadata when available, including rate-limit headers. `info.files()` returns the file list as a single value on success so it can be passed directly to `ba.json.encode(info.files())`.

### `info.files([opts])`

Returns a recursive list of repository entries using GitHub's tree API. Each entry uses a path relative to the repository root, so the name can be passed back to GitHub IO operations such as `open`, `stat`, `remove`, or `rmdir`.

`opts.branch` or `opts.ref` can override the configured branch for this call.

Example return data:

```json
[
  {
    "name": "README.md",
    "type": "file",
    "githubType": "blob",
    "mode": "100644",
    "sha": "9e1e2aee17b5c980420008fb3602a2d7387d0fd0",
    "size": 5735
  },
  {
    "name": "www",
    "type": "dir",
    "githubType": "tree",
    "mode": "040000",
    "sha": "9e2a0441ebf149a2b2f50435195ce9941072ebfb"
  }
]
```

The `type` field is normalized from GitHub's tree metadata:

- `file` means a regular repository file
- `dir` means a directory
- `submodule` means a Git submodule entry

The `size` field is provided when GitHub reports it, normally for files. `sha`, `mode`, and `githubType` expose the underlying tree metadata. Empty-directory marker files named `.keep` are hidden from this list because they are an implementation detail used to emulate empty directories.

GitHub can truncate very large recursive tree responses. Check `files.truncated` after calling `info.files()` if your repository is large.

This helper is different from the LuaIo `ghio:files(path)` method. `ghio:files(path)` is the standard BAS directory iterator for one directory at a time. `info.files()` is a GitHub-specific recursive listing helper for the whole repository.

Use `info.files()` when you need a recursive file list. Building your own recursive iterator on top of `ghio:files(path)` would require one GitHub contents request for every directory in the repository. That can be very slow for larger repositories and can also consume more GitHub API quota. `info.files()` asks GitHub for the recursive tree in one request and then normalizes the returned paths for GitHub IO operations.

### Repository and refs

```lua
local repo = info.repo()
local defaultBranch = info.defaultBranch()
local branches = info.branches()
local tags = info.tags()
local refs = info.refs("heads")
```

- `info.repo()` returns normalized repository metadata such as owner, repository name, full name, default branch, clone URLs, size, and visibility.
- `info.defaultBranch()` returns the repository's default branch name.
- `info.branches([opts])` returns branch names, commit SHAs, and protection flags.
- `info.tags([opts])` returns tag names and commit SHAs.
- `info.refs([prefix])` returns Git refs. Use prefixes such as `"heads"` or `"tags"` to narrow the response.

List helpers use pagination. Pass `perPage` and `maxPages` when you want to tune how many GitHub pages are fetched.

### Commit metadata

```lua
local commits = info.commits("www/.lua/GitHubIo.lua", { perPage = 10 })
local modified = info.lastModified("README.md")
local diff = info.compare("main", "feature-branch")
```

- `info.commits([path], [opts])` returns normalized commits. `opts` may include `branch`, `ref`, `sha`, `since`, `until`, `author`, `committer`, `perPage`, and `maxPages`.
- `info.lastModified(path, [opts])` returns the newest commit metadata for one path. Use this when you need a real GitHub modification time instead of the normalized `mtime` used by LuaIo `stat`.
- `info.compare(base, head)` returns compare status, ahead/behind counts, normalized commits, and changed files between two refs.

These helpers are intentionally separate from `stat`. Looking up real modification times requires commit history calls, which are much more expensive than a normal file metadata lookup.

### Rate limits and archives

```lua
local limits = info.rateLimit()
local zipData = info.archive("zip", "main")
local tarData = info.archive("tar", "main")
```

- `info.rateLimit()` returns GitHub's current rate-limit resource data.
- `info.archive(format, [ref])` downloads a repository archive. `format` may be `"zip"`, `"zipball"`, `"tar"`, `"tar.gz"`, or `"tarball"`.

### Batch commits

```lua
local commit, err = info.commitBatch({
   { path = "README.md", content = "# New content\n" },
   { path = "www/index.html", content = "<h1>Hello</h1>\n" },
   { path = "old.txt", delete = true },
}, "Update site files")
```

`info.commitBatch(changes, message, [opts])` writes multiple file changes as one Git commit by using GitHub's lower-level Git database API. This is useful when several files should change atomically or when you want a cleaner history than one commit per file. It requires a token with write access.

Each change supports:

- `path` or `name` for the repository-relative file path
- `content` or `data` for raw content
- `b64content` for already-base64-encoded content
- `delete = true` or `remove = true` to delete a file
- `mode` for Git mode, defaulting to `"100644"`

`opts.branch` can override the configured branch. `opts.force = true` updates the branch ref forcibly and should only be used when the caller has already decided that overwriting history is acceptable.
