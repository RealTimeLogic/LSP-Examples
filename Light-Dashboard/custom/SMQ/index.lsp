<?lsp

-- CMS-level SMQ WebSocket endpoint. The shared page shell connects here
-- on full page load; HTMX fragment navigation keeps the connection alive.
local hub=require"smq.hub"

if hub.isSMQ(request) then
   app.connectSmqClient(request)
   response:abort()
end

response:senderror(400,"Not an SMQ connection request")

?>
