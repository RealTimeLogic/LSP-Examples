# Easy CSRF prevention using the 'referer' header

Cross-Site Request Forgery (CSRF) prevention is a security measure employed by web applications to safeguard against unauthorized commands issued from a trusted user (authenticated user). CSRF attacks exploit the trust a site has in a user's browser, enabling an attacker to execute unwanted actions in a web application in which the user is authenticated. Without CSRF prevention mechanisms in place, a malicious actor could potentially manipulate a user into performing actions they did not intend.

CSRF attacks are more commonly associated with public-facing web applications and not so much with servers running within an Intranet since the attacker would need to know the Intranet address for the server.

This example shows how to implement CSRF prevention using the browser's "referer" header. The example also shows how to implement a CSRF token, but this token is only used for the initial handshake. However, you may optionally choose to use the CSRF token for general CSRF prevention. The token is generated as follows:

``` Lua
--Create token
encryptedtoken = ba.aesencode(secret, ba.json.encode{time=ba.datetime"NOW":tostring()})

--Decode token
token = ba.json.decode(ba.aesdecode(secret, encryptedtoken)
```

The above encrypted token includes a timestamp which the server side can use to verify that the token has not expired.

See the documentation for more information on:
- [ba.aesencode](https://realtimelogic.com/ba/doc/?url=lua/lua.html#ba_aesencode)
- [ba.aesdecode](https://realtimelogic.com/ba/doc/?url=lua/lua.html#ba_aesdecode)
- [ba.json.encode](https://realtimelogic.com/ba/doc/?url=lua/lua.html#json_encode)
- [ba.json.decode](https://realtimelogic.com/ba/doc/?url=lua/lua.html#json_decode)
- [ba.datetime](https://realtimelogic.com/ba/doc/?url=lua/lua.html#ba_datetime)

When using the browser's referrer header for CSRF prevention, you need to be aware of your server's name. For an Intranet server, it might be tempting to hard-code this to the server's IP address, but in practice, this can change due to factors like Intranet DNS services or [SharkTrustX](https://realtimelogic.com/products/SharkTrustX/) providing dynamic names. Therefore, simply using the server's IP address for comparison with the referrer header is not reliable.

In our example, we use the CSRF token primarily to discover the server's name dynamically. This could be an IP address or any other identifier; the server could even have multiple names provided by DNS.

The first page the user visits, the [main index page](index.lsp), initiates a trusted handshake to automatically discover the server's name. This page uses support functions from the [.preload](.preload) script to generate a CSRF token and store the server's name. JavaScript in the index page handles this handshake and then redirects the user to [myapp/index.lsp](myapp/index.lsp), which includes an HTML form that is protected using the referrer header.

Run the example, using the Mako Server, as follows:

``` shell
mako -l::CSRF-Prevention
```

For detailed instructions on starting the Mako Server, check out our [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and review the server's [command line options](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp) in our documentation.
