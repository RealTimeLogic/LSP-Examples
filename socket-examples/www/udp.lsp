<pre>
<?lsp

local portno=45738

-- Wait for data on port 45738 and print the data
local function udpRecCosocket()
   local sock,err = ba.socket.udpcon(portno) -- bind to 45738
   if not sock then trace("Failed:",err) return end
   local err
   while true do
      local data,address,port = sock:read(true)
      if not data then err=address break end
      trace(data,address,port)
   end
   trace("Exiting udpRecCosocket", err)
end

-- Create a connection-less socket and send a broadcast message every
-- second
local function udpSendCosocket()
   local sock,err = ba.socket.udpcon() -- Connection less
   if not sock then trace("Failed:",err) return end
   sock:setoption("broadcast", true) -- Required when sending broadcast msgs
   local cnt,err=1
   while true do
      local data
      -- Connection less thus we cannot receive data; we use it as a timer
      data,err = sock:read(1000) -- Wait one sec.
      assert(data == nil)
      if "timeout" ~= err then break end -- if not a timeout
      -- Send message using the broadcast address 255.255.255.255
      sock:sendto(string.format("Message %d",cnt),"255.255.255.255",portno) 
      cnt=cnt+1
   end
   trace("Exiting udpSendCosocket", err)
end

-- Triggers on page refresh or on close via "POST"
if page.r then
   trace"Terminating udpRecCosocket and udpSendCosocket"
   page.r:close()
   page.s:close()
end

if request:data"stop" then
   trace"User navigating away from web page"
else
   trace"Creating udpRecCosocket and udpSendCosocket"
   page.r=ba.socket.event(udpRecCosocket)
   page.s=ba.socket.event(udpSendCosocket)
end

?>
</pre>
<h2>See console for printouts</h2>
<script>
function sendclose() {
    var client = new XMLHttpRequest();
    client.open("GET", "<?lsp=request:url()?>?stop=", true);
    client.send();
};
window.addEventListener('beforeunload', sendclose, false);
</script>
