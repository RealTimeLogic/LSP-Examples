<?lsp
local uname,appname,authtype=request:user()
?>
<!DOCTYPE html>
<html>
  <head>
    <link type="text/css" href="/style.css" rel="Stylesheet" />
  </head>
<body>
<main>
  <?lsp if uname then ?>
    <p>You are authenticated as "<?lsp=uname?>" using "<?lsp=authtype?>" authentication.</p>
  <?lsp else ?>
    <p>You are <b>not</b> authenticated.</p>
  <?lsp end ?>
  <p><a href="my-protected/">Navigate to the protected directory</a></p>
</main>
</body>
</html>
