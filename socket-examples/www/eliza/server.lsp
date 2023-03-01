<?lsp

-- function elizaSockCoroutine is in .lua/eliza.lua
-- The function is loaded and stored in 'app' table by .preload
assert(app.elizaSockCoroutine)

local s = ba.socket.req2sock(request)
if s then
   s:event(app.elizaSockCoroutine,"s")
else
   print"Connect using WebSockets!"
end

?>
