<?lsp
local activeMenuItem = menuT[relpath] or {href="",name=""}
local authenticated = request:user() and true or false

local function emitMenu()
   for _,m in ipairs(menuL) do
      if not m.auth or authenticated then
         response:write('<li class="pure-menu-item"><a href="',m.href,'" class="pure-menu-link',activeMenuItem == m and ' pure-menu-selected' or '','">',m.name,'</a></li>')
      end
   end
end

?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?lsp=activeMenuItem.name?></title>
    <link rel="stylesheet" href="/static/pure-min.css">
    <link rel="stylesheet" href="/static/styles.css">
</head>
<body>

<div id="layout">
    <!-- Menu toggle -->
    <a href="#menu" id="menuLink" class="menu-link">
        <!-- Hamburger icon -->
        <span></span>
    </a>
    <div id="menu">
        <div class="pure-menu">
            <a class="pure-menu-heading" href="https://realtimelogic.com/">Company</a>
            <ul class="pure-menu-list">
                <?lsp emitMenu() ?>
            </ul>
        </div>
    </div>
    <div id="main">
        <?lsp lspPage(_ENV,relpath,io,page,app) ?>
    </div>
</div>

<script src="/static/ui.js"></script>

</body>
</html>
