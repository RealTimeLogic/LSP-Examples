
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

<form method="post">
   <?lsp if username then ?>
      <h1>Hello <?lsp=username?></h1>
      <input type = "submit" value="Logout">
   <?lsp else ?>
      <input type = "text" name="username">
      <input type = "submit" value="Login">
   <?lsp end ?>
</form>

