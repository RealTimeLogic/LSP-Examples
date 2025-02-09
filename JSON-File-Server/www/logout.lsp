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
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            background-color: #f4f4f4;
        }
        .message-container {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            max-width:500px;
        }
        h2{text-align: center;}
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

