<pre>

<?lsp
local s,err = ba.socket.connect("time.nist.gov",37)
if s then
   local d
   d,err = s:read(5000) -- Wait a maximum of 5 seconds for response
   if d and #d == 4 then
      -- Create 32 bit word from received data in network endian.
      local t = ba.socket.n2h(4,d)
      t = t - 2208988800 -- Convert from 1900 to 1970 format
      print("NTP Date and time:",os.date("%c",t))
   end
   s:close()
end
if err then
   print(err)
end
?>

</pre>
