# Blocking (Easy) Upload

This example shows how to use
[request:rawrdr()](https://realtimelogic.com/ba/doc/?url=lua.html#request_rawrdr)
for drag and drop upload and
[request:multipart()](https://realtimelogic.com/ba/doc/?url=lua.html#request_multipart)
for standard file upload. The two functions request:rawrdr() and
request:multipart() are much easier to use than the asynchronous
versions of these two functions, however, the functions require a
thread enabled server such as the Mako Server.

![Blocking Upload](www/doc/overview.png "Blocking Upload")

Run the example, using the Mako Server, as follows:

```
cd upload/blocking
mako -l::www
```
