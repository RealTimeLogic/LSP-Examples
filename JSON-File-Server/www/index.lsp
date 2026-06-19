
<?lsp

if request:user() then
   response:sendredirect"logout.lsp"
end

local username=request:data"username"
if username and "POST" == request:method() then
   if "nil" == username then
     username=nil
     trace"Setting username to nil"
   end
   trace(string.format("Auto logging in using the username '%s'",username))
   if request:login(username) then
      response:sendredirect"fs/"
   else
      trace"Cannot login"
      response:sendredirect""
   end
end
?>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Auto Login</title>
    <style>
        body {
            margin: 0;
            padding: 32px;
            background: #1e1f22;
            color: #d7dbd8;
            font: 16px/1.5 system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        }
        .login-container {
            max-width: 560px;
            margin: 8vh auto 0;
            border: 1px solid #454856;
            border-radius: 8px;
            padding: 22px;
            background: #2d2f34;
        }
        h2 {
            color: #f2f4f3;
        }
        a {
            color: #ffd12b;
        }
        select, button {
            box-sizing: border-box;
            border-radius: 6px;
            padding: 10px 12px;
            font: inherit;
        }
        select {
            width: 100%;
            border: 1px solid #454856;
            background: #252526;
            color: #f2f4f3;
        }
        button {
            border: 0;
            background: #69c575;
            color: #1e1f22;
            font-weight: 700;
            cursor: pointer;
        }
        li {
            margin-bottom: 8px;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <h2>Two Login Options</h2>
        <ul>
            <li><a href="fs/">Navigate to the File Server</a> and log in using HTTP Digest Authentication</li>
            <li>Select a user below to auto-login via <code>request:login(username)</code></li>
        </ul>

        <h2>Programmatic Login</h2>
        <form method="POST" action="">
            <select id="userSelect" name="username">
                <option value="mom">Mom</option>
                <option value="dad">Dad</option>
                <option value="kids">Kids</option>
                <option value="guest">Guest</option>
                <option value="anonymous">Anonymous</option>
                <option value="nil">(nil)</option>
            </select>
            <br>
            <button type="submit">Login</button>
        </form>
    </div>
</body>
</html>
