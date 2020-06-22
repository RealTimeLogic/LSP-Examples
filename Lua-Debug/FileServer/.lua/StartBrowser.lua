
--[[


The sole purpose with this 'app' is to start the browser and navigate
to the server.



--]]

local dio=ba.openio"disk"
local fmt=string.format

--WFS or Mako Server
local serverport = (ba and ba.serverport) or (mako and mako.port)
local isblocked=true

local function startbrowser()
   local cmd
   local _,type=dio:resourcetype()
   if type == "windows" then
      cmd="start"
   else
      function findcmd(cmd)
         cmd=ba.exec("command -v "..cmd)
         if cmd then
            cmd=cmd:gsub("^%s*(.-)%s*$", "%1")
            return dio:stat(cmd) and cmd
         end
      end
      for _,x in ipairs{"xdg-open","x-www-browser","gnome-open"} do
         cmd=findcmd(x)
         if cmd then break end
      end
   end
   if cmd then
      cmd = fmt("%s http://localhost:%d",cmd,serverport)
      local timer
      local function timerfunc()
         local function yield() coroutine.yield(true) end
         while isblocked do yield() end
         ba.thread.create():run(function() ba.exec(cmd) end)
      end
      timer=ba.timer(timerfunc)
      timer:set(1000,true,true)
   end
end

if serverport and ba.socket and ba.thread.run then -- If installed
   ba.thread.run(function()
      startbrowser()
      ba.sleep(200)
      local count=0
      while true do
         local ok=true
         -- Check if PC firewall blocks the server port.
         if pcall(function() require "http" end) then
            local http=require"http"
            ok = http.create{persistent=false}:request{
               url=fmt("http://127.0.0.1:%d",serverport),
               method="HEAD"
            }
         end
         if ok then
            if count > 0 then print"Server unblocked and ready!" end
            isblocked=false
            break
         else
            print"\n\n--------------  WARNING --------------------"
            print("Your firewall is blocking the server ports!!!")
            print("Please unblock the server.")
            print(fmt("%c",7))
            ba.sleep(4000)
         end
         count=count+1
      end
   end)
end
