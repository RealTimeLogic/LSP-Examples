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
     <link rel='shortcut icon' type='image/x-icon' href='/public/favicon.ico' />
  </head>
<body>

<p>You are executing index.lsp</p>
<p>You are authenticated as "<?lsp=uname?>" using "<?lsp=authtype?>" authentication.</p>
<p><a href="./?logout=true">Logout</a></p>
<?lsp if authtype ~= 'form' then?>
<p><b>Note:</b>The browser will automatically log you in again when using Basic or Digest authentication. The only way to logout is to close the browser!</p>
<?lsp end?>
</body>
</html>
