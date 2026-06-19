<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Forwarded Command Environment</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
<main>
<h1>Forwarded Command Environment</h1>
<p>This page is reached by forwarding through <code>first.lsp</code> and <code>.second.lsp</code>.</p>
<pre>
<?lsp


-- Your solution, which works
local session = request:session()
trace("In third: holdnewvar", session.holdnewvar)
trace("In third: myvar", myvar,"\n")
print("In third: holdnewvar", session.holdnewvar)
print("In third: myvar", myvar)



?>
</pre>
</main>
</body>
</html>
