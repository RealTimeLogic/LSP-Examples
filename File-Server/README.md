# WebDAV and Web File Server

## Overview

This example creates a Web File Server plus WebDAV endpoint mounted at `/fs/`. It is compatible with BAS products that have a file system, including the Mako Server and Xedge32.

![Web File Manager and WebDAV](https://makoserver.net/images/Win-WebDAV.png "Web File Manager and WebDAV")

Reference material:

- [WebDAV overview](https://realtimelogic.com/products/webdav/)
- [How to Create a Cloud Storage Server](https://makoserver.net/articles/How-to-Create-a-Cloud-Storage-Server)

## Files

- `www/.preload` - Creates the WebDAV IO, configures the lock directory, mounts the web file server at `/fs/`, and applies basic authentication.

## How to run

Start the example with the Mako Server:

```bash
cd File-Server
mako -l::www
```

For more detail on startup options, see the [Mako command line video](https://youtu.be/vwQ52ZC5RRg) and the [Mako command line options documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

Then open:

- `http://localhost:portno/fs/`

where `portno` is the HTTP port printed by the server.

Login credentials:

- Username: `admin`
- Password: `admin`

For WebDAV drive mapping guidance, see:

- https://youtu.be/i5ubScGwUOc

## How it works

The startup script opens a writable IO, creates a lock directory, loads the `wfs` support, and mounts a Web File Server instance at `/fs/`. It then creates a small username/password callback that authenticates `admin` / `admin`, wraps that callback in a BAS authenticator, and applies the authenticator to the mounted directory. When the app unloads, the `/fs/` mount is removed cleanly.

## Notes / Troubleshooting

- On Windows, avoid mapping `http://localhost/fs/` directly. Use a more specific path such as `http://localhost/fs/C/` to avoid recursive lookup issues.
- This app intentionally focuses on the `/fs/` endpoint and does not add extra HTML pages around it.
