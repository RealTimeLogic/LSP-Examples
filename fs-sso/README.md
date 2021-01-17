This example shows how to implement Single Sign On (SSO) using
[OpenID Connect](https://openid.net/connect/).
The example is designed for [Microsoft Azure AD](https://portal.azure.com/).

Authenticated users are provided access to a
[WebDAV](https://realtimelogic.com/products/webdav/)
session URL, enabling registered and authenticated users to map the
server as a network drive.

To use the example, create a mako.conf file with the following
settings:

```
openid={
   tenant="your tenant id",
   client_id="your client id",
   client_secret="your client secret",
   redirect_uri="https://localhost/"
}
```

For testing on 'localhost', use the redirect_uri as shown above.

See the Microsoft tutorial
[Register an application with the Microsoft identity platform](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-configure-app-expose-web-apis)
for how to obtain the above required settings. Platform settings must be
"Web", under section Add credentials, select Add a client
secret. Click next to continue with the [next tutorial](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-configure-app-access-web-apis), including section
[Add permissions to access Microsoft Graph](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-configure-app-access-web-apis#add-permissions-to-access-microsoft-graph).

Run the example, using the Mako Server, as follows:

```
cd fs-sso
mako -l::www
```

See the
[Mako Server command line video tutorial](https://youtu.be/vwQ52ZC5RRg)
for more information on how to start the Mako Server.





