<?lsp title="Admin" response:include".header.lsp" ?>
<h1>Admin</h1>

<p>This application is the example for the <a href="https://makoserver.net/articles/Dynamic-Navigation-Menu">Dynamic Navigation Menu</a> tutorial. This application also includes authentication.</p>

<p>Pages included in the menu:</p>
<ul>
<li><a href="showsource/?path=network.lsp">network.lsp</a></li>
<li><a href="showsource/?path=security.lsp">security.lsp</a></li>
<li><a href="showsource/?path=users.lsp">users.lsp</a></li>
<li><a href="showsource/?path=admin.lsp">admin.lsp</a></li>
</ul>

<ul>
<li><a href="showsource/?path=index.lsp">index.lsp</a> - Redirects to admin.lsp</li>
</ul>

<p>Hidden pages available to server side code:</p>

<ul>
<li><a href="showsource/?path=.404.lsp">.404.lsp</a> - logic in .preload redirects 404 to this page</li>
<li><a href="showsource/?path=.header.lsp">.header.lsp</a> - included by most pages</li>
<li><a href="showsource/?path=footer.shtml">footer.shtml</a> - included by most pages</li>
<li><a href="showsource/?path=.login-form.lsp">.login-form.lsp</a> - logic in .preload redirects to this page when not authenticated</li>
<li><a href="showsource/?path=.preload">.preload</a> - the app's authentication and 404 management</li>
</ul>

<p>Pages that are always available, even when not authenticated:</p>

<ul>
<li><a href="showsource/?path=public/style.css">public/style.css</a> - app's style</li>
<li><a href="showsource/?path=public/login-style.css">public/login-style.css</a> - style for login page</li>
<li><a href="showsource/?path=public/login-error.js">public/login-error.js</a> - makes the login form shake</li>
<li><a href="showsource/?path=public/recover-password.lsp">public/recover-password.lsp</a> - you may implement recovery logic here</li>
</ul>

<p><b>Click any link above to see the source code.</b></p>

<p>Check out the <a href="this page does not exist">404 page!</a></p>

<h2>References:</h2>
<ul>
<li><a href="https://realtimelogic.com/ba/doc/?url=lua.html#auth_overview">Introduction to Lua Authentication and Authorization</a></li>
<li><a href="https://realtimelogic.com/ba/doc/en/lua/auth.html">HA1 hashed passwords</a></li>
<li><a href="https://realtimelogic.com/ba/doc/?url=lua.html#ba_create_jsonuser">JSON Authenticator</a></li>
<li><a href="https://realtimelogic.com/ba/doc/en/lua/lua.html#ba_create_resrdr">The app's predefined 'dir' object type</a></li>
<li><a href="https://realtimelogic.com/ba/doc/?url=lua.html#CMDE">_ENV and how to pass variables to included pages</a></li>
</ul>


<?lsp response:include"footer.shtml" ?>
