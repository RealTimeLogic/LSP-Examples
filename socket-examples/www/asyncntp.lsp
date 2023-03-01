<pre>
<?lsp
local s,err = ba.socket.connect("time.nist.gov",37)
if not s then
   print(err)
else
   local t -- The time 't' is set when received
   local function asyncRead(s)
      local d
      d,err = s:read(5000) -- Wait a maximum of 5 seconds for response
      if d and #d == 4 then
         -- Create 32 bit word from received data in network endian.
         t = ba.socket.n2h(4,d)
         t = t - 2208988800 -- Convert from 1900 to 1970 format
      else
         print("Failed", err)
         t=-1
      end
   end -- Socket 's' is closed when coroutine returns
   s:event(asyncRead,"r")
   -- Let LSP page wait for asynchronous response
   while not t do ba.sleep(100) end
   if t > 0 then
      print("NTP Date and time:",os.date("%c",t))
   else
      print'Note that the TCP based "TIME" service at "time.nist.gov" sometimes fail'
   end
end
?>
</pre>
