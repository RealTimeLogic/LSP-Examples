<?lsp

   -- This ESP32 CAM example captures images from the camera and sends
   -- them to the browser via WebSockets using the SMQ protocol:
   -- https://realtimelogic.com/ba/doc/?url=SMQ.html

   -- Settings for Seeed Studio XIAO ESP32S3 Sense
   -- Doc: https://realtimelogic.com/ba/ESP32/source/cam.html#the-configuration-table
   -- Make sure to the test the simpler camread.lsp example prior to
   -- running this example with your cam config.
   local cfg={
      d0=15, d1=17, d2=18, d3=16, d4=14, d5=12, d6=11, d7=48,
      xclk=10, pclk=13, vsync=38, href=47, sda=40, scl=39, pwdn=-1,
      reset=-1, freq="20000000", frame="HD"
   }

   -- Delegate to SMQ if this is a WebSocket request
   if request:header"Sec-WebSocket-Key" then
       -- Create and store a broker in the persistent 'page' table
      local smq = page.smq
      if not smq then
         smq=require"smq.hub".create() -- Create one broker instance
         page.smq=smq -- Store broker instance
         smq:observe("img",function(subscribers)
            trace("Image subscribers:",subscribers)
            if 0 == subscribers then
               trace"Stopping cam timer"
               page.timer:cancel()
               smq:shutdown()
               if page.cam then page.cam:close() end
               page.smq,page.cam,page.timer=nil,nil,nil
            end
         end)
         page.timer=ba.timer(function()
            local busy,cnt,err=false,4
            page.cam,err=esp32.cam(cfg)
            if not page.cam then
               local msg = string.format("Cannot open cam: %s",err)
               trace(msg)
               smq:publish(msg,"info")
               return
            end
            local cam=page.cam
            while page.timer do
               local left,inQ=smq:queuesize()
               if inQ < 2 and not busy then
                  busy=true
                  ba.thread.run(function()
                     local img,err=cam:read()
                     if img then
                        -- if larger than max SMQ packet size
                        if #img > 0xFFF0 then
                           local size = #img
                           local pos = 1
                           while size > 0 do
                              local chunkSize = math.min(size, 0xFFF0)
                              local chunk = img:sub(pos, pos + chunkSize - 1)
                              pos = pos + chunkSize
                              size = size - chunkSize
                              local topic = 0 == size and "img/assemble" or "img/chunk"
                              smq:publish(chunk, topic)
                           end
                        else
                           smq:publish(img, "img")
                        end
                        cnt=cnt+1
                        if 0 == cnt % 5 then
                           local ap=esp32.apinfo()
                           smq:publish(tostring(ap and ap.rssi or -100),"rssi")
                        end
                     else
                        trace("cam:read()",err)
                     end
                     busy=false
                  end) -- thread
               end
               coroutine.yield(true) -- wait 4 next timer tick
            end -- loop
         end)  -- timer func
         page.timer:set(200)
      end -- not smq
      smq:connect(request) -- Morph HTTP to SMQ WS connection
      return -- We are done
   end
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Cam Images Over WebSockets (SMQ)</title>
  <style>
  body{
      background:black;
      color:white;
  }
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
  <script src="/rtl/smq.js"></script>
<script>
window.addEventListener("load", (event) => {
  let img = document.getElementById("image");
  let msg = document.getElementById("msg");
  let frameCounter=0;
  let rssi="?";

  function setImg(imgChunkArray) {
    const blob = new Blob(imgChunkArray, { type: 'image/jpeg' });
    img.src = URL.createObjectURL(blob);
    frameCounter++;
    msg.textContent = `Frames: ${frameCounter}, RSSI: ${rssi}`;
  };

  let smq = SMQ.Client(SMQ.wsURL(window.location.pathname),{cleanstart:true});

  smq.onconnect=(etid, rnd, ipaddr) => {
    console.log("onconnect, client's Ephemeral Topic ID="+etid);
    msg.textContent="Connected; Waiting for images...";
    smq.subscribe("info", {datatype:"text", onmsg: (msg) => msg.textContent=msg});
    smq.subscribe("img", {onmsg: (img) => setImg([img])});
    let chunks = [];
    smq.subscribe("img/chunk", {onmsg: (imgChunk) => chunks.push(imgChunk)});
    smq.subscribe("img/assemble", {onmsg: (imgChunk) => {
      chunks.push(imgChunk);
      setImg(chunks);
      chunks = [];
    }});
    smq.subscribe("rssi", {datatype:"text", onmsg: (x) => rssi=x});
  };

  smq.onreconnect=smq.onconnect;
  smq.onclose=(message,canreconnect) => {
    console.log("onclose, reason="+message+", canreconnect="+canreconnect);
    msg.textContent = 'Disconnected, reconnecting...';
    return 1000; // Wait one sec before reconnecting
  };
});
</script>
</head>
<body>
  <h2>Cam Images Over WebSockets (SMQ)</h2>
  <div id="image-container">
    <img id="image"/>
  </div>
  <p id="msg">Connecting...</p>
</body>
</html>
