# WebDAV and Web File Server

This document includes the example 1 source code for the [How to Create a Cloud Storage Server Tutorial](https://makoserver.net/articles/How-to-Create-a-Cloud-Storage-Server). This example is compatible with any [BAS](https://realtimelogic.com/products/barracuda-application-server/) derivative product with a file system, including the Mako Server and Xedge32.

Run the example, using the Mako Server, as follows:

```
cd File-Server
mako -l::www
```

For detailed instructions on starting the Mako Server, please refer to our [Mako Server command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and review the [server's command line options](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp) in our documentation.

Once you've successfully started the Mako Server, open a web browser and go to http://localhost:portno/fs/, where 'portno' represents the HTTP port number used by the Mako Server (this number is displayed in the console).

To access the system, use the following login credentials:
- Username: 'admin'
- Password: 'admin'
    
For guidance on how to map the WebDAV drive, watch this instructional video: https://youtu.be/i5ubScGwUOc

Important note for Windows users: Avoid mapping the URL http://localhost/fs/ as it may result in an endless file system lookup loop. Instead, consider using another computer or mapping one of the drives, such as http://localhost/fs/C/.

Please be aware that this application does not contain any web pages or resources except for the WebDAV/file-server installed at /fs/. Additional information can be found in the www/.preload Lua script.



