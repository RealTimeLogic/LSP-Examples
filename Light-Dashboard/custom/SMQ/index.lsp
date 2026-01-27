<?lsp

-- JS code in the WebSockets.html page (in WebSockets.js) connects to
-- this page to set up an SMQ WebSocket Connection.

-- Doc: https://realtimelogic.com/ba/doc/en/SMQ.html
if require"smq.hub".isSMQ(request) then
   -- Upgrade HTTP(S) request to SMQ connection
   -- See code in the .preload script (the app).
   app.connectClientSlider(request) -- Function in the .preload script
   response:abort() -- stop executing page
end

?>
