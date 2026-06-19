<?lsp

local user,_,authtype=request:user()

request:logout(true)

trace("Authenticator type:", "?" == authtype and "request:login()" or authtype)

if not user or "digest" ~= authtype then
   response:sendredirect"./"
end

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cannot Log Out</title>
    <style>
        body {
            margin: 0;
            padding: 32px;
            background: #1e1f22;
            color: #d7dbd8;
            font: 16px/1.5 system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        }
        .message-container {
            max-width: 620px;
            margin: 8vh auto 0;
            border: 1px solid #454856;
            border-radius: 8px;
            padding: 22px;
            background: #2d2f34;
        }
        h2 {
            color: #f2f4f3;
            text-align: center;
        }
        a {
            color: #ffd12b;
        }
    </style>
</head>
<body>
    <div class="message-container">
        <h2>Cannot Log Out</h2>
        <p>You are using HTTP Digest Authentication and logged in as '<?lsp=user?>'. Even though you have been logged out on the server side, your browser will automatically re-authenticate when you navigate back to the <a href="fs/">File Server</a>.</p>
        <p>HTTP authentication credentials are cached by your browser until you fully close all browser windows. Be aware that some browsers may remain in memory even after all visible windows are closed.</p>
<p>You can return to the <a href="./">main index page</a> and log in using the auto-login option. Additionally, you can switch users by selecting a different auto-login option, instantly assuming their identity. Automatic HTTP authentication occurs only when accessing the File Server while not already logged in on the server side.</p>
    </div>
</body>
</html>

