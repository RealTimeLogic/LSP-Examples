<?lsp
if request:data"logout" == "true" then
   request:logout()
   response:sendredirect""
end
local uname,appname,authtype=request:user()
?>
<!DOCTYPE html>
<html>
  <head>
  </head>
<body>
<p>You are authenticated as "<?lsp=uname?>" using "<?lsp=authtype?>" authentication.</p>
<p><a href="/">Navigate to the non protected directory</a></p>
<p><a href="./?logout=true">Logout</a></p>
<?lsp if authtype ~= 'form' then?>
<p><b>Note:</b>The browser will automatically log you in again when using Basic or Digest authentication. The only way to logout is to close the browser!</p>
<?lsp end?>
</body>
</html>
