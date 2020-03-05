<html>
<body>

<h1>Wiki Index</h1>
<?lsp

local pages=0 -- Pages in Wiki

-- sqlutil select callback. Emit all wiki entries as html links.
local function emitlinks(cur)
   local relpath,data = cur:fetch()
   while relpath do
      response:write("<a href='",relpath,"'>",relpath,"</a><br>")
      relpath,data = cur:fetch()
      pages = pages +1
   end
end
local su=require"sqlutil"
-- Execute SQL: SELECT relpath,data FROM wiki
su.select(function() return su.open"wiki" end,"relpath,data FROM wiki",emitlinks)

if pages==0 then
   response:write"<p>You do not have any pages. <a href='my-first-wiki-page'>Create a page</a>.</p>"
end

?>

</body>
</html>
