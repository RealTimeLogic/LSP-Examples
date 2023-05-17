<?lsp

-- This ESP32 CAM example captures images from the camera and sends
-- them to the browser via WebSockets. The example employs a basic
-- self-regulating flow control mechanism. Initially, the server-side
-- code reads and sends one image to the browser. Upon receiving the
-- image, the browser sends a short response message back to the
-- server. Then, the server fetches another image and sends it to the
-- browser. This cycle repeats as long as the client is connected. The
-- example supports multiple browser clients by maintaining a list of
-- connected sockets. The WebSocket sendMessage() function iterates
-- over all connected sockets, transmitting image data to each
-- one. Note that this LSP page stores persistent data in the
-- persistent page table. For more information on the page object,
-- refer to the following link:
-- https://realtimelogic.com/ba/doc/?url=lua.html#CMDE

local cfg={
   d0=5,
   d1=18,
   d2=19,
   d3=21,
   d4=36,
   d5=39,
   d6=34,
   d7=35,
   xclk=0,
   pclk=22,
   vsync=25,
   href=23,
   sda=26,
   scl=27,
   pwdn=32,
   frame="HD"
}

if request:header"Sec-WebSocket-Key" then
   local s = ba.socket.req2sock(request)
   if s then
      trace"New client"
      local sockets=page.sockets or {}
      page.sockets=sockets
      sockets[s]=true
      if not page.cam then
         trace"Creating cam object"
         local function sendMessage(data,txtFrame)
            for s in pairs(sockets) do
               s:write(#data <= 0xFFFF and data or "", txtFrame)
            end
         end
         local function sendJson(data)
            sendMessage(ba.json.encode(data),true)
         end
         local function sendImage(data)
            page.messages = page.messages + page.clients
            sendMessage(data)
         end
         
         local cnt=0
         function page.sendImage()
            if not page.cam then return end
            local img,err = page.cam:read()
            if img then
               if 0 == cnt % 10 then
                  local ap=esp32.apinfo()
                  sendJson{type="rssi",rssi=ap and ap.rssi or -100}
               end
               cnt=cnt+1
               sendMessage(img,false)
            else
               local msg = "Reading failed: "..(err or "")
               trace(msg)
               sendJson{type="error",emsg=msg}
            end
            page.processing=false
         end
         local err
         page.cam,err=esp32.cam(cfg)
         if not page.cam then
            local msg = "Cannot open cam: "..(err or "")
            trace(msg)
            s:write(msg,true)
            page.sockets=nil
            ba.sleep(100)
            esp32.execute"restart"
            return
         end
         page.clients=0
         page.messages=0
         page.processing=true
         page.sendImage()
      end
      page.clients=page.clients+1
      local function decMessages()
         if page.messages > 0 then page.messages = page.messages - 1 end
      end
      s:event(function(s)
                 while s:read() do
                    decMessages()
                    if 0 == page.messages and not page.processing then
                       page.processing=true
                       ba.thread.run(page.sendImage)
                    end
                 end
                 sockets[s]=nil
                 trace"Closing client"
                 page.clients=page.clients-1
                 decMessages()
                 if 0 == page.clients then
                    trace"Closing cam"
                    page.cam:close()
                    page.cam=nil
                 else
                    ba.thread.run(page.sendImage)
                 end
              end, "r")
   end
   return -- Done WS
end
-- Else: standard HTTP GET -- i.e. load page below
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Cam Images Over WebSockets</title>
  <style>
    /* Add the following CSS */
    #image-container {
      display: flex;
      justify-content: center;
      align-items: center;
      width: 100%;
    }
    #image {
      max-width: 100%;
      height: auto;
    }
    h2, p {
    text-align: center;
    }
  </style>
</head>
<body>
    <h2>Cam Images Over WebSockets</h2>
   <div id="image-container">
    <img id="image"/>
  </div>
    <p id="msg">Connecting...</p>
<script>

function connect() {
    let rssi=-127;
    let socketURL = '<?lsp=string.format("ws%s://%s",request:issecure() and 's' or '',
                     request:url():match".-//(.+)")?>';
    let ws = new WebSocket(socketURL);
    ws.binaryType = 'arraybuffer';
    let img = document.getElementById("image");
    let msg = document.getElementById("msg");
    let frameCounter=0;
    let chkCounter=0;
    let intvTimer=null;
    ws.onopen=function() {
        msg.textContent="Connected; Waiting for image...";
        intvTimer=setInterval(function() {
            if(frameCounter == chkCounter) {
                msg.textContent="Checking server...";
                ws.send("ok");
            }
            chkCounter=frameCounter;
        }, 7000);
    };
    ws.onmessage=function(event) {
        if(event.data instanceof ArrayBuffer) {
            if(event.data.byteLength > 1) {
                const blob = new Blob([event.data], { type: 'image/jpeg' });
                img.src = URL.createObjectURL(blob);
                frameCounter++;
                msg.textContent = `Frames: ${frameCounter}, RSSI: ${rssi}`;
            }
            else {
                msg.textContent = "Image too big";
            }
            ws.send("ok");
        }
        else { // Text, error message
            let msg=JSON.parse(event.data);
            if(!msg || "error" == msg.type) {
                msg.textContent = `Server error: ${msg ? msg.emsg : "invalid JSON"}`;
                ws.close();
            }
            switch(msg.type) {
            case "rssi":
                rssi=msg.rssi;
                break;
            default:
                console.log("Unknown message type",msg.type);
            }
        }
    };
    ws.onclose = function() {
        if(intvTimer) clearInterval(intvTimer);
        intvTimer=null;
        msg.textContent = 'Disconnected, reconnecting...';
        setTimeout(connect, 3000);
    };
};
window.onload = connect;
</script>
</body>
</html>
