<?lsp

-- Debugging Wi-Fi Signal Strength with ESP32 and Xedge32

-- Details:
--  https://realtimelogic.com/articles/Debugging-WiFi-Signal-Strength-with-ESP32-and-Xedge32

if page.s then
   response:senderror(503,"Busy: in use by another page")
   return
end

local ap=esp32.apinfo()
if request:header"Sec-WebSocket-Key" then
   local s = ba.socket.req2sock(request)
   if s then
      local page=page
      page.s=s
      local rssi=ap.rssi
      trace"Creating ws conn"
      s:event(function()
         local timer=ba.timer(function()
            local ap=esp32.apinfo()
            if ap.rssi ~= rssi then
               rssi=ap.rssi
               s:write(rssi,true)
            end
            return true
         end)
         timer:set(100)
         s:read() -- wait for socket close
         timer:cancel()
         page.s=nil
         trace"Closing ws conn"
      end,"s")
      return -- We are done
   end
end
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WiFi Information</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            background-color: #f4f4f9;
            color: #333;
        }

        .rssi {
            font-size: 3rem;
            font-weight: bold;
            color: #ff5722;
            margin-bottom: 1rem;
            text-align: center;
        }

        table {
            width: 90%;
            max-width: 500px;
            border-collapse: collapse;
            background: #fff;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
            overflow: hidden;
        }

        th, td {
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }

        th {
            background-color: #6200ea;
            color: #fff;
            text-transform: uppercase;
            font-size: 0.9rem;
        }

        tr:last-child td {
            border-bottom: none;
        }

        td {
            font-size: 1rem;
        }

        .status {
            margin-top: 1rem;
            font-size: 1.2rem;
            color: #555;
        }
    </style>
</head>
<body>
    <div class="rssi">RSSI: <span id="rssi"><?lsp=ap.rssi?></span></div>

    <table>
        <thead>
            <tr>
                <th>Property</th>
                <th>Value</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>SSID</td>
                <td><?lsp=ap.ssid ?></td>
            </tr>
            <tr>
                <td>Channel</td>
                <td><?lsp=ap.channel ?></td>
            </tr>
            <tr>
                <td>GCipher</td>
                <td><?lsp=ap.gcipher ?></td>
            </tr>
            <tr>
                <td>PCipher</td>
                <td><?lsp=ap.pchiper ?></td>
            </tr>
            <tr>
                <td>AuthMode</td>
                <td><?lsp=ap.authmode ?></td>
            </tr>
        </tbody>
    </table>

    <div class="status" id="status">WebSocket Status: Connecting...</div>

    <script>
        let websocket;

        function getWebSocketURL() {
            const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
            const host = window.location.host;
            const path = window.location.pathname;
            return `${protocol}//${host}${path}`;
        }

        function connectWebSocket() {
            const wsURL = getWebSocketURL();
            websocket = new WebSocket(wsURL);

            websocket.onopen = function() {
                document.getElementById("status").textContent = "WebSocket Status: Connected";
            };

            websocket.onclose = function() {
                document.getElementById("status").textContent = "WebSocket Status: Disconnected. Reconnecting...";
                setTimeout(connectWebSocket, 3000); // Reconnect after 3 seconds
            };

            websocket.onerror = function(error) {
                console.error("WebSocket Error: ", error);
            };

            let rssi=document.getElementById("rssi")
            websocket.onmessage = function(event) {
                rssi.textContent=event.data
            };
        }

        window.onbeforeunload=()=> websocket.close()

        // Initialize WebSocket connection
        connectWebSocket();
    </script>
</body>
</html>
