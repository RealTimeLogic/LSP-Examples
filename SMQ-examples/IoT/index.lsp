<!DOCTYPE html>
<html lang="en">
<head>
<meta name=viewport content="width=device-width, initial-scale=1"/>
<link rel="stylesheet" type="text/css" href="https://realtimelogic.com/ba/doc/style.css" />
<style>

#maindiv {
max-width: 900px;
margin:auto;
}
</style>
<title>SMQ IoT Tutorials</title>
</head>
<body>
<div id="maindiv">
<?lsp

local markdown = io:dofile".lua/markdown.lua"
local fp <close> = io:open"README.md"
response:write(markdown(fp:read"*a"))

?>
</div>
</body>
</html>
