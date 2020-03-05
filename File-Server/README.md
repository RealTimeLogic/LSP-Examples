# WebDAV and Web-File-Server

This is the companion example for the [How to Create a Cloud Storage Server](https://makoserver.net/articles/How-to-Create-a-Cloud-Storage-Server) tutorial.

Run the example, using the Mako Server, as follows:

```
cd File-Server
mako -l::www
```

See the [Mako Server command line video tutorial](https://youtu.be/vwQ52ZC5RRg) for more information on how to start the Mako Server.

After starting the Mako Server, use a browser and navigate to
http://localhost:portno/fs/, where portno is the HTTP port number used by
the Mako Server (printed in the console).

Login using the username 'admin' and the password 'admin'.

See the following video for how to map the WebDAV drive:
https://youtu.be/i5ubScGwUOc

On Windows, make sure not to map the URL http://localhost/fs/ as this
will create an endless file system lookup loop. Either use another
computer or map one of the drives such as http://localhost/fs/C/.

Note: this application has no web pages or resources, except for the
WebDAV/file-server installed at /fs/. See the www/.preload script for details.



