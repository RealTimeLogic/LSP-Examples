<!--

You end up at the first line in this LSP page If you click the
debugger's pause button prior to loading the index page in the
browser. You may then step through this code. You can set a breakpoint
on any of the Lua source code lines below.

If you step through this code, you will notice that the debugger also
lets you step over some of the HTML, which may initially confuse
you. LSP is converted into Lua code and the auto generated Lua code
includes some hidden _emit(data) code sections.

Set a breakpoint on line 38 below. The listprint() function is used as
a callback for each element printed by the Markov chain module.

-->
<!DOCTYPE html>
<html lang="en">
<head>
  <title>LSP Example Page</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
</head>
<body>
<div class="jumbotron text-center">
  <h1>Debug this page</h1>
</div>
<div class="container">

<?lsp

response:write'<h2>Markov chain data</h2>'

response:write'<ul class="list-group">'

local function listprint(elem)
   response:write('<li class="list-group-item">',elem,'</li>')
end

-- Load the module
local mc = require"Markow-Chain"



mc.run(listprint)


response:write'</ul>'


?>

</div>
</body>
</html>
