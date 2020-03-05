<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<title><?lsp=title?></title>
<link rel="stylesheet" href="/public/style.css" />
<script src='/rtl/jquery.js'></script>
<?lsp response:write(extheader or "") ?>
</head>
<body>
<div id="nav"><ul>
<?lsp

local links={
   {'network.lsp','Network'},
   {'security.lsp','Security'},
   {'users.lsp','Users'},
   {'admin.lsp','Admin'}
}

for _,link in ipairs(links) do
   local isactive = title == link[2]
   response:write('<li><a href="/',link[1],'"', isactive and ' class="selected"' or '','>',link[2],'</a></li>')
end

?>
</ul></div>
<div id="maincontent">
