<html>
<body>
<h1>Automatic cluster configuration</h1>
<ul>
<?lsp

local function print(...)
   response:write("<li>",...,"</li>")
end

-- Start: code ripped from FuguHub

local function trim(s)
   return s:gsub("^%s*(.-)%s*$", "%1")
end

local function runIfConfig(command)
   local resp = ba.exec(command)
   if resp then
      resp = trim(resp)
      if #resp == 0 then
         resp=nil
      end
   end
   return resp
end
 
local function getIpListWindows()
   local ip = {} -- List of IP addresses (network cards)
   local ipconf = runIfConfig("ipconfig")
   if not ipconf then
      ipconf = runIfConfig[[%SystemRoot%\system32\ipconfig]]
   end
   if ipconf then
      for ipa in string.gmatch(
       ipconf,
       "IP[v]?[4]? Address[^%d]-(%d+%.%d+%.%d+%.%d+)") do
         table.insert(ip, ipa)
      end
   end
   return ip
end


local function getIpListUnix()
   local gw = {} -- List of gateways
   local ip = {} -- List of IP addresses (network cards)
   local ipconf = runIfConfig("ifconfig")
   if not ipconf then
      ipconf = runIfConfig("/sbin/ifconfig")
   end
   if ipconf then
      -- Linux
      local s="inet addr:(%d+%.%d+%.%d+%.%d+)"
      if not string.find(ipconf,s) then
         -- Mac
         s="inet[^\n]-(%d+%.%d+%.%d+%.%d+)"
      end
      for ipa in string.gmatch(ipconf,s) do
         table.insert(ip, ipa)
      end
   end
   return ip
end

local hio=ba.openio"home"

function getIpList()
   local _,op=hio:resourcetype()
   if op == "windows" then
      return getIpListWindows()
   end
   return getIpListUnix()
end

-- End: code ripped from FuguHub

local list=getIpList()

if #list < 2 then ?>
<p>This script is unable to find a sufficient number of network interfaces. Consider creating a new loopback adapter. See the documentation for details.</p>
<?lsp else

local fmt=string.format

local winexec=ba.openio"disk":realpath(mako.execpath)

for _,ipaddr in pairs(list) do
   print("Creating "..ipaddr..".cmd")
   local fp,err = hio:open(ipaddr..".cmd","w")
   if not fp then print("Failed: "..err) break end
   fp:write(fmt("%s\\mako -c %s.conf -l::www\n",winexec,ipaddr))
   fp:close()
   print("Creating "..ipaddr..".conf")
   local fp = hio:open(ipaddr..".conf","w")
   fp:write(fmt('host="%s"\nsslhost="%s"\n',ipaddr,ipaddr))
   fp:close()
end

print("Creating all.cmd")
local fp = hio:open("all.cmd","w")
for _,ipaddr in pairs(list) do
   fp:write(fmt("start %s.cmd\n",ipaddr))
end
fp:close()
print("Creating www/ip-address-list.lua")
local fp = hio:open("www/ip-address-list.lua","w")
fp:write("return {\n")
for _,ipaddr in pairs(list) do
   fp:write(fmt('\t"%s",\n',ipaddr))
end
fp:write("}\n")
fp:close()

?>
</ul>

<p>Configuration files created!<br>Stop the server, run "all.cmd", and navigate to two of:
<?lsp for _,ipaddr in pairs(list) do response:write(ipaddr,', ') end ?>
</p>
<?lsp end ?>
</body>
</html>
