<?lsp

if not page.smq then
   -- The following code would normally be put in a .preload/.config
   -- script.
   page.smq = require"smq.hub".create()
   trace"SMQ broker installed."
end
if require"smq.hub".isSMQ(request) then
   -- Upgrade HTTP(S) request to SMQ connection
   page.smq:connect(request)
else -- Not an SMQ client
   response:senderror(400, "Not an SMQ Connection Request!")
end
?>

