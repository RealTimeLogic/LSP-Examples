# Lua Authentication Examples

The following provides a practical introduction to the Barracuda App
Server's authentication mechanism. The examples are designed to be run
as root applications by using the Mako Server and should be started
from the command line as follows:

```console
mako -l::dir-name
```

The Barracuda authenticators are designed such that they can be
decoupled from the resource(s) they protect. One benefit with such a
solution is that it eliminates security holes that could be introduced
in a per page based authentication mechanism.

# Credentials

Login to any of the examples below using the username 'admin' and the password 'admin'.

Note: you must restart the browser when switching from digest or basic
authentication to any other authentication mechanism.

# Prerequisite:

Authenticator Concept:
http://realtimelogic.com/ba/doc/?url=doc/en/authentication.html

Introduction to Lua Authentication:
https://realtimelogic.com/ba/doc/?url=en/lua/lua.html#auth_overview

# Example "root"

```console
mako -l::root
mako -l::root digest|form
```

The first command sets up HTTP basic authentication. The second
command sets up HTTP digest or form based authentication.

The "root" application installs an authenticator on the root
directory, i.e. on the top directory in the virtual file system. Note
that some resources must be available to the browser when the user is
not authenticated. These resources are placed in the /public/
directory, which is always public when using a Resource Reader
directory instance. See dir:setauth() for details:

https://realtimelogic.com/ba/doc/en/lua/lua.html#ba_dir_setauth

# Example "subdir"

```console
mako -l::subdir
mako -l:: subdir digest|form
```

The first command sets up HTTP basic authentication. The second
command sets up HTTP digest or form based authentication.

The subdir example provides one possible solution for a system
requiring authentication on a subset of an application. An
authenticator inserted into a directory covers the entire directory;
thus this example does not insert an authenticator directly into the
resource reader. Instead, a virtual directory branch is constructed
with the purpose of protecting the physical resources in a
subdirectory (subset) of the resource reader.

# Example "semiautomatic"

```console
mako -l::semiautomatic
```

One of the great benefits with setting an authenticator on a directory
is that it helps the programmer in making sure the authentication
logic is consistent and does not have any security holes. For example,
new pages that are added to a protected directory are automatically
protected since the authentication logic is decoupled from the pages
in the application.

However, sometimes an application may require fine grained control of
the authentication process on a per page basis. The semiautomatic
example shows how one can use the authenticators to implement a per
page authentication mechanism.

One of the problems with implementing a per page authentication
mechanism is that you could forget to add authentication to a page,
thus introducing a security hole. One solution to this problem is to
make sure the page looks different (as in a program error) if you
forget to add the authentication logic. We have for this reason
combined the authentication logic with an example of how to implement
a basic menu system. Each page in this example includes a "header" and
a "footer", in which the header includes the authenticator and the
menu system, and the footer includes the end of the HTML. The header
and footer are common to all pages.

# Securing form based authentication

Form based authentication is more common as it enables a customized
HTML login page. All of the above examples use or can use form based
authentication. Note that the authentication mechanism is not secure
when using HTTP in any of the above examples.

If you plan on using form based authentication with non encrypted
HTTP, make sure to use the secure version as explained in the
following section:
https://realtimelogic.com/ba/doc/en/lua/lua.html#EncryptedPasswords

The tutorial Dynamic Navigation Menu includes form based
authentication that is secure on plain old HTTP. The example also
shows how to store credentials on the server side as hashed values,
thus protecting the credentials should the server's file system be
compromised.

https://makoserver.net/articles/Dynamic-Navigation-Menu

# Additional Examples

- [Single Sign On using OpenID Connect](../fs-sso/README.md)
