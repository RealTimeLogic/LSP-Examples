# Authentication and Authorization Example

This example shows how to enable both authentication and authorization using an Access Control List (ACL). The **Barracuda App Server (BAS)** provides several API functions for managing authentication and, optionally, authorization. See the [authenticator documentation](https://realtimelogic.com/ba/doc/en/lua/lua.html#auth_overview) for details.

## Authentication vs. Authorization

- **Authentication** verifies the identity of a user.
- **Authorization** determines what resources a user can access after authentication.

While applications may implement their own ACL directly, this example utilizes both authentication and authorization APIs provided by BAS. We use the easy-to-use **[JSON Authenticator](https://realtimelogic.com/ba/doc/en/lua/lua.html#ba_create_jsonuser)**, which includes an optional authorizer that assigns permissions based on the following:
- The authenticated user
- A predefined set of URIs
- The HTTP method used

## File Server Integration

This example applies the combined authenticator and authorizer to a **[File Server object](https://realtimelogic.com/ba/doc/en/lua/lua.html#ba_create_wfs)**, which integrates:
- **WebDAV**, enabling file management through WebDAV clients.
- **Web File Manager**, allowing users to browse and manage files through a web interface.

For details on using WebDAV, refer to the tutorial [How to Create a Cloud Storage Server](https://makoserver.net/articles/How-to-Create-a-Cloud-Storage-Server).

**Note:** The **JSON Authenticator** is not restricted to use with a **File Server** object. It can also be used in standard web applications, offering an easy to implement authentication mechanism. Additionally, its built-in authorization capabilities provide a convenient way to manage access control within your application.


## User Database and ACL Configuration

The user database and ACL setup are also covered in the tutorial **How to Create a Cloud Storage**, section **[Creating a User Database](https://makoserver.net/articles/How-to-Create-a-Cloud-Storage-Server#udb)**.

To keep the example concise, user credentials and ACL rules are **hardcoded** within the [.preload](www/.preload) script.

## Authentication and Authorization

### HTTP Digest Authentication

This example uses **[HTTP Digest Authentication](https://realtimelogic.com/ba/doc/en/authentication.html#authtypes)**, which prompts users for credentials via a browser pop-up. Note that:
- Browsers **cache** the HTTP credentials until they are completely closed.
- Some browsers may keep processes in memory even after closing all windows, retaining authentication.

### Hardcoded User Credentials

The following credentials are preconfigured in this example:

| Username | Password |
|----------|----------|
| guest    | guest    |
| kids     | kids     |
| mom      | mom      |
| dad      | dad      |


### Server-Side Authentication via request:login()

This example also shows how to use the [request:login()](https://realtimelogic.com/ba/doc/en/lua/lua.html#request_login) method, which allows server-side code to authenticate a user without relying on **HTTP authentication** or the web-based authentication mechanisms provided by **BAS**. This method is designed for integrating authentication systems not natively supported by the server, such as **[Single Sign-On](../fs-sso/README.md) (SSO)** or **WebAuthn**.

#### Using `request:login()` with an Authorizer

In this example, `request:login()` is used alongside an **authorizer**. When an authorizer is enabled:
- `request:login()` **must** be called with valid user credentials.
- Attempting to log in without arguments or with a non-existent user will be denied.

The `index.lsp` page demonstrates this by allowing authentication with the registered users: **mom, dad, kids, and guest**. It also provides options to:
- Attempt authentication with `nil` (Lua's equivalent of "no value").
- Logging in as an unregistered user.

When using an unregistered user, authentication succeeds, but the authorizer **blocks access** and returns a "No Access" message.

#### Testing Without an Authorizer

The included `mako.conf` file contains a setting that is read by the `.preload` script. This setting allows you to **disable the authorizer** for testing purposes. Without an authorizer, `request:login()` grants access to the protected **File Server** resource regardless of the username provided.




## How to Use the Example

This example is designed to run on the **[Mako Server](https://makoserver.net/download/overview/)**. To start the example, navigate to the project directory and launch the server with the following command:

```sh
cd JSON-File-Server
mako -l::www
```

For detailed instructions on starting the Mako Server, please refer to our [Mako Server command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and review the [server's command line options](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp) in our documentation.

Once you have successfully started the Mako Server, open a web browser and navigate to http://localhost:portno, where 'portno' represents the HTTP port number used by the Mako Server (this number is displayed in the console).

On this page, you can:
- **Access the File Server** at `fs/` and log in using **HTTP Digest Authentication**.
- **Test `request:login()`** to authenticate users programmatically.

Try the different login methods and observe how authentication works. When using **HTTP Digest Authentication**, the browser's login dialog will prompt for credentials - enter one of the **usernames and passwords** [listed above](#hardcoded-user-credentials).

After testing the login methods, stop the server and open [mako.conf](mako.conf) in an editor, remove the comment to disable the authorizer, and re-start the server.

## Files in the `www` Directory

- **`.preload`** - The [.preload startup script](https://realtimelogic.com/ba/doc/en/Mako.html#preload) configures the **authenticator** and **authorizer** using hardcoded values. It initializes a **File Server instance** and integrates it into the **[Virtual File System](https://realtimelogic.com/ba/doc/en/VirtualFileSystem.html) (VFS)**. Additionally, the script sets up a directory structure on your hard drive for use by the File Server.

- **`index.lsp`** - Provides navigation options:
  - Access the **File Server** at `fs/` and log in using **Digest Authentication**.
  - Authenticate using `request:login()`.
  - If already authenticated, accessing this page will redirect you to `logout.lsp`.

- **`logout.lsp`** - Handles user logout:
  - Logs the user out and redirects the users back to `index.lsp`, except for those using **Digest Authentication** (due to browser-based credential caching).
  - Displays additional logout-related details when not redirected.
