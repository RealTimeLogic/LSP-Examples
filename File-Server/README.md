# WebDAV and Web File Server

This example provides a Web File Server + WebDAV endpoint mounted at `/fs/`.
It is compatible with [Barracuda App Server](https://realtimelogic.com/products/barracuda-application-server/) derivatives that have a file system, including Mako Server and Xedge32.


![Web File Manager and WebDAV](https://makoserver.net/images/Win-WebDAV.png "[Web File Manager and WebDAV")

## References

- [WebDAV overview](https://realtimelogic.com/products/webdav/)  
  A quick product-level introduction to Real Time Logic's WebDAV support and use cases.

- [How to Create a Cloud Storage Server](https://makoserver.net/articles/How-to-Create-a-Cloud-Storage-Server)  
  Step-by-step tutorial this example is based on (this repo corresponds to Example 1 from that article).

## Quick Start (Mako Server)

```bash
cd File-Server
mako -l::www
```

If you need more detail on startup options, see:

- [Mako Server command line video](https://youtu.be/vwQ52ZC5RRg)
- [Mako Server command line options](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp)

## Access the File Server

Open:

- `http://localhost:portno/fs/`

`portno` is the HTTP port shown in the Mako Server console.

Login credentials:

- Username: `admin`
- Password: `admin`

For WebDAV drive mapping guidance:

- https://youtu.be/i5ubScGwUOc

## Notes

- Windows: avoid mapping `http://localhost/fs/` directly; use a specific drive path such as `http://localhost/fs/C/` to avoid recursive lookup issues.
- This app does not include extra pages/resources beyond the WebDAV/file-server at `/fs/`.
- See `www/.preload` for implementation details.



