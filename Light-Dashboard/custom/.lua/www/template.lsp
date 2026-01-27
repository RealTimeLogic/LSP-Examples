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
-- class 'is-active' for the active page.
local function emitMenu()
   local function isVisible(item)
      return not item.auth or authenticated
   end

   local function isActive(item)
      return activeMenuItem == item
   end

   for _,m in ipairs(menuL) do
      local hasChildren = m.children and #m.children > 0
      if hasChildren then
         local visibleChildren = {}
         local childActive = false
         for _,child in ipairs(m.children) do
            if isVisible(child) then
               visibleChildren[#visibleChildren + 1] = child
               if isActive(child) then
                  childActive = true
               end
            end
         end

         local showGroupLink = m.href and isVisible(m)
         local showGroup = showGroupLink or #visibleChildren > 0

         if showGroup then
            local groupActive = childActive or isActive(m)
            response:write('<li class="nav-item nav-group',groupActive and ' is-active' or '','">')
            if showGroupLink then
               response:write('<a href="',m.href,'" hx-get="',m.href,'" hx-push-url="true" hx-target="#main" class="nav-group-title',isActive(m) and ' is-active' or '','"',isActive(m) and ' aria-current="page"' or '','>',m.name,'</a>')
            else
               response:write('<span class="nav-group-title">',m.name,'</span>')
            end
            if #visibleChildren > 0 then
               response:write('<ul class="nav-sublist">')
               for _,child in ipairs(visibleChildren) do
                  local activeChild = isActive(child)
                  response:write('<li class="nav-subitem"><a href="',child.href,'" hx-get="',child.href,'" hx-push-url="true" hx-target="#main" class="nav-sublink',activeChild and ' is-active' or '','"',activeChild and ' aria-current="page"' or '','>',child.name,'</a></li>')
               end
               response:write('</ul>')
            end
            response:write('</li>')
         end
      else
         if isVisible(m) then
            local itemActive = isActive(m)
            response:write('<li class="nav-item"><a href="',m.href,'" hx-get="',m.href,'" hx-push-url="true" hx-target="#main" class="nav-link',itemActive and ' is-active' or '','"',itemActive and ' aria-current="page"' or '','>',m.name,'</a></li>')
         end
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
    <link rel="stylesheet" href="/static/styles.css">
    <script src="https://unpkg.com/htmx.org@2.0.3"></script>
</head>
<body>

<div id="layout" class="app-shell">
    <!-- Menu toggle -->
    <a href="#menu" id="menuLink" class="menu-link" aria-label="Toggle navigation">
        <!-- Hamburger icon -->
        <span></span>
    </a>
    <div id="menu" class="side-nav">
        <div class="nav-inner">
            <a class="nav-brand" href="https://realtimelogic.com/">Company</a>
            <ul class="nav-list">
                <?lsp emitMenu() ?>
            </ul>
        </div>
    </div>
    <div id="main" class="main-pane">
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
