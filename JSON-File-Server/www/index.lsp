
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
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            background-color: #f4f4f4;
        }
        .login-container {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            text-align: center;
        }
        select, button {
            padding: 10px;
            margin-top: 10px;
            font-size: 16px;
        }
        li{
            list-style: none;
            text-align: left;
           margin-bottom:5px;

        } 
        li::before{ 
            content: "\1F882";

        }
        li
    </style>
</head>
<body>
    <div class="login-container">
        <h2>Two Login Options:</h2>
        <ul>
            <li><a href="fs/">Navigate to the File Server</a> and log in using HTTP Digest Authentication</li>
            <li>Select a user below to auto-login via <code>request:login(username)</code></li>
        </ul>

        <h2>Auto Login</h2>
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
