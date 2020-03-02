<pre>
<?lsp

print'\n--- dofile"helloworld1.lua" ----'
io:dofile"helloworld1.lua"
hello()

print'\n--- dofile"helloworld1.lua" using t as env ----'
local t=setmetatable({},{__index=_G})
io:dofile("helloworld1.lua",t)
t.hello()

print'\n--- require"helloworld2".hello() ----'
require"helloworld2".hello()

print'\n--- require"subdir.helloworld3".hello() ----'
require"subdir.helloworld3".hello()

print" ============== Setting _ENV to LSP _ENV ============="

print'\n--- require"helloworld2".hello() ----'
require"helloworld2".hello(_ENV)

print'\n--- require"subdir.helloworld3".hello() ----'
require"subdir.helloworld3".hello(_ENV)


?>
</pre>
