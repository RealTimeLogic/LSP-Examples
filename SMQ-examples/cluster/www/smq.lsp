<?lsp

if not request:header"SimpleMQ" and not request:header"Sec-WebSocket-Key" then
   -- Page should only be used by SMQ
   response:sendredirect"https://realtimelogic.com/ba/doc/?url=SMQ.html"
end

app.connect(request)
?>

