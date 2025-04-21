<?lsp

-- This LSP page is parsed and executed as a Lua function by the
-- directory callback function in cms.lua. The content rendered by
-- this page is the left side content as shown in Figure 3 ->
-- https://makoserver.net/articles/How-to-Build-an-Interactive-Dashboard-App
-- See the lspPage() call below for how the right side is injected.

-- _ENV.menuT saved in request/resp. env. by directory callback
local activeMenuItem = menuT[relpath] or {href="",name=""}
local authenticated = request:user() and true or false

-- This function creates the navigation menu. Notice how we use the
-- class 'pure-menu-selected' for the active page.
local function emitMenu()
   for _,m in ipairs(menuL) do
      if not m.auth or authenticated then
         response:write('<li class="pure-menu-item"><a href="',m.href,'"hx-get="',m.href,'" hx-push-url="true" hx-target="#main" class="pure-menu-link',activeMenuItem == m and ' pure-menu-selected' or '','">',m.name,'</a></li>')
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
    <script src="https://unpkg.com/htmx.org@2.0.3"></script>
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
        <?lsp
             -- Call _ENV.lspPage (set by directory callback in cms.lua) and
             -- inject page content.
             lspPage(_ENV,relpath,io,page,app)
             if not response:valid() then return end
        ?>
    </div>
</div>

<script src="/static/ui.js"></script>

</body>
</html>
