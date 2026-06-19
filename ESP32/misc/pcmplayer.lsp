<?lsp

-- An example that shows how to sample a microphone or any other sound
-- source and how to send the sampled data to the browser. We use a
-- JavaScript PCM Player library to play the sampled data in the
-- browser (https://github.com/samirkumardas/pcm-player). The example
-- supports multiple browser clients by maintaining a list of
-- connected WebSocket connections.

if request:header"Sec-WebSocket-Key" then
   local s = ba.socket.req2sock(request)
   if s then
      trace"New WebSocket connection"
      local sockets=page.sockets or {}
      page.sockets=sockets
      if not page.adc then
         local function onData(data,err)
            if data then
                for s in pairs(sockets) do s:write(data) end
            else
                trace(err)
            end
         end
         page.adc=esp32.adc(1, 0, {
                               bl=20000,
                               callback=onData,
                               fs=20000,
                               filter="data",
                            })
      end
      sockets[s]=true
      s:event(function(s)
                 s:read()
                 sockets[s]=nil
                 if not next(sockets) then
                    page.adc:close()  -- Close ADC if no more clients
                    page.adc=nil
                 end
              end, "s")
      return
   end
end
?>
<!DOCTYPE html>
<html lang="en">
<head>
   <script src="https://cdn.jsdelivr.net/npm/pcm-player-ex@0.3.10/dist/index.min.js"></script>
   <meta charset="UTF-8">
   <title>ESP32 PCM Audio Stream</title>
   <style>
      body {
         margin: 0;
         padding: 32px;
         background: #1e1f22;
         color: #d7dbd8;
         font: 16px/1.5 system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      }
      #container {
         max-width: 520px;
         margin: 10vh auto 0;
         border: 1px solid #454856;
         border-radius: 8px;
         padding: 20px;
         background: #2d2f34;
      }
      h2 {
         margin-top: 0;
         color: #f2f4f3;
      }
   </style>
</head>
<body>
<div id="container">
    <h2>ESP32 PCM Audio Stream</h2>
    <p>This page connects to the ESP32 audio WebSocket endpoint and plays incoming PCM samples in the browser.</p>
    <p>If your browser blocks autoplay, click anywhere on the page to allow audio playback.</p>
</div>
<script>
 window.onload = function() {
   var socketURL = 'ws://<?lsp=request:url():match".-//(.+)"?>';
   var player = new PCMPlayer({
        encoding: 'Int16',
        channels: 1,
        sampleRate: 17000,
        flushingTime: 0,
        volume: 1
   });

     var ws = new WebSocket(socketURL);
     ws.binaryType = 'arraybuffer';
     ws.addEventListener('message',function(event) {
         var data = new Uint8Array(event.data);
         player.feed(data);
     });
 }   
</script>
</body>
</html>
