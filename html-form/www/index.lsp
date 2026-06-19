
<?lsp
local username
local session = request:session()
local data=request:data()
if request:method() == "POST" then
   if data.username then
      username=data.username
      request:session(true).username=username
   elseif session then
      session:terminate()
   end
else
   username = session and session.username
end
?>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>HTML Form Example</title>
    <style>
      body {
        margin: 0;
        padding: 32px;
        background: #1e1f22;
        color: #d7dbd8;
        font: 16px/1.5 system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      }
      main {
        max-width: 520px;
        margin: 0 auto;
      }
      h1 {
        color: #f2f4f3;
      }
      form {
        border: 1px solid #454856;
        border-radius: 8px;
        padding: 20px;
        background: #2d2f34;
      }
      input {
        box-sizing: border-box;
        border: 1px solid #454856;
        border-radius: 6px;
        padding: 10px 12px;
        background: #252526;
        color: #f2f4f3;
        font: inherit;
      }
      input[type="text"] {
        width: 100%;
        margin-bottom: 12px;
      }
      input[type="submit"] {
        border: 0;
        background: #69c575;
        color: #1e1f22;
        font-weight: 700;
        cursor: pointer;
      }
    </style>
  </head>
  <body>
    <main>
      <form method="post">
         <?lsp if username then ?>
            <h1>Hello <?lsp=username?></h1>
            <p>The submitted username is stored in the session. Submit again to terminate the session.</p>
            <input type="submit" value="Logout">
         <?lsp else ?>
            <h1>HTML Form Example</h1>
            <p>Enter any username and submit the form. This beginner example stores the value in the session.</p>
            <input type="text" name="username" autocomplete="off">
            <input type="submit" value="Login">
         <?lsp end ?>
      </form>
    </main>
  </body>
</html>
