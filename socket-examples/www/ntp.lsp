NTP Date and time (local server time):
<?lsp
local function printTime()
   local s,err = ba.socket.udpcon("pool.ntp.org",123)
   if s then
      s:write(string.char(27)..string.char(0):rep(47))
      local d,err=s:read(5000)
      if d and #d == 48 then
         local secs = ba.socket.n2h(4,d,41)
         secs = secs - 2208988800 -- Convert from 1900 to 1970 format
         print(os.date("%c",secs))
      else
         print"Invalid response"
      end
      s:close()
   else
      print("Cannot connect:",err)
   end
end
printTime()
?>
