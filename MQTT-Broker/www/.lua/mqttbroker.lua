-- Minimal MQTT 3.1.1 / MQTT 5.0 QoS 0 broker for BAS cosockets.
local fmt=string.format
local sbyte,ssub=string.byte,string.sub
local tinsert=table.insert
local TRACE=false

local function dbg(...)
   if TRACE then trace("mqttbroker:",...) end
end

local btaCreate,btaCopy,btah2n,btan2h,btaSize,btaSetsize,bta2string=
   ba.bytearray.create,ba.bytearray.copy,ba.bytearray.h2n,ba.bytearray.n2h,
   ba.bytearray.size,ba.bytearray.setsize,ba.bytearray.tostring

local MQTT_CONNECT    =0x01<<4
local MQTT_CONNACK    =0x02<<4
local MQTT_PUBLISH    =0x03<<4
local MQTT_PUBACK     =0x04<<4
local MQTT_PUBREC     =0x05<<4
local MQTT_PUBREL     =0x06<<4
local MQTT_PUBCOMP    =0x07<<4
local MQTT_SUBSCRIBE  =0x08<<4
local MQTT_SUBACK     =0x09<<4
local MQTT_UNSUBSCRIBE=0x0a<<4
local MQTT_UNSUBACK   =0x0b<<4
local MQTT_PINGREQ    =0x0c<<4
local MQTT_PINGRESP   =0x0d<<4
local MQTT_DISCONNECT =0x0e<<4

local function now()
   return ba.clock()//1000
end

local function optErr(name,exp,got)
   error(fmt("%s: expected %s, got %s",name,exp,type(got)),3)
end

local function chkType(name,val,typ)
   if type(val) ~= typ then optErr(name,typ,val) end
end

local function encVBInt(bta,ix,len)
   if bta then
      local digit
      repeat
         digit=len % 0x80
         len=len // 0x80
         if len > 0 then digit=digit | 0x80 end
         bta[ix]=digit
         ix=ix+1
      until len == 0
      return ix
   end
   repeat
      len=len // 0x80
      ix=ix+1
   until len == 0
   return ix
end

local function encByte(bta,ix,byte)
   if bta then bta[ix]=byte end
   return ix+1
end

local function enc2BInt(bta,ix,number)
   if bta then btah2n(bta,ix,2,number) end
   return ix+2
end

local function enc4BInt(bta,ix,number)
   if bta then btah2n(bta,ix,4,number) end
   return ix+4
end

local function encString(bta,ix,str)
   local len=#str
   if bta then
      btah2n(bta,ix,2,len)
      bta[ix+2]=str
   end
   return ix+2+len
end

local encBinData=encString

local function btaCreate2(packetLen)
   return btaCreate(1+encVBInt(nil,0,packetLen)+packetLen)
end

local function decVBInt(bta,ix)
   local mult,len,count=1,0,0
   local total=btaSize(bta)
   while true do
      if ix > total or count == 4 then return nil,ix,"protocolerror" end
      local digit=bta[ix]
      len=len+(digit&0x7F)*mult
      ix=ix+1
      count=count+1
      if digit < 0x80 then return len,ix end
      mult=mult*0x80
   end
end

local function decByte(bta,ix)
   if ix > btaSize(bta) then return nil,ix,"protocolerror" end
   return bta[ix],ix+1
end

local function dec2BInt(bta,ix)
   if ix+1 > btaSize(bta) then return nil,ix,"protocolerror" end
   return btan2h(bta,ix,2),ix+2
end

local function dec4BInt(bta,ix)
   if ix+3 > btaSize(bta) then return nil,ix,"protocolerror" end
   return btan2h(bta,ix,4),ix+4
end

local function decString(bta,ix)
   local total=btaSize(bta)
   if ix+1 > total then return nil,ix,"protocolerror" end
   local len=btan2h(bta,ix,2)
   ix=ix+2
   if ix+len-1 > total then return nil,ix,"protocolerror" end
   if len == 0 then return "",ix end
   return bta2string(bta,ix,ix+len-1),ix+len
end

local decBinData=decString

local propName={
   [17]="sessionexpiryinterval",
   [21]="authenticationMethod",
   [22]="authenticationData",
   [23]="requestProblemInformation",
   [39]="maximumPacketSize"
}

local function skipProps(bta,ix)
   local propLen
   propLen,ix=decVBInt(bta,ix)
   if not propLen then return nil,nil,"protocolerror" end
   local endIx=ix+propLen
   if endIx-1 > btaSize(bta) then return nil,nil,"protocolerror" end
   local propT={}
   while ix < endIx do
      local id=bta[ix]
      ix=ix+1
      if id == 35 then
         return nil,nil,"protocolerror"
      elseif id == 38 then
         local dummy
         dummy,ix=decString(bta,ix)
         if not dummy then return nil,nil,"protocolerror" end
         dummy,ix=decString(bta,ix)
         if not dummy then return nil,nil,"protocolerror" end
      else
         local val
         if id == 1 or id == 23 or id == 36 or id == 37 or
            id == 40 or id == 41 or id == 42 then
            val,ix=decByte(bta,ix)
         elseif id == 19 or id == 33 or id == 34 then
            val,ix=dec2BInt(bta,ix)
         elseif id == 2 or id == 17 or id == 24 or id == 39 then
            val,ix=dec4BInt(bta,ix)
         elseif id == 11 then
            val,ix=decVBInt(bta,ix)
         elseif id == 3 or id == 8 or id == 18 or id == 21 or
            id == 26 or id == 28 or id == 31 then
            val,ix=decString(bta,ix)
         elseif id == 9 or id == 22 then
            val,ix=decBinData(bta,ix)
         else
            return nil,nil,"protocolerror"
         end
         if not val then return nil,nil,"protocolerror" end
         local name=propName[id]
         if name then propT[name]=val end
      end
   end
   if ix == endIx then return propT,ix end
   return nil,nil,"protocolerror"
end

local function emitError(broker,client,etype,status)
   local onerror=broker.opt.onerror
   if onerror then pcall(onerror,client,etype,status) end
end

local function defaultOnpub(topic)
   trace("Received unhandled local MQTT topic",topic)
end

local function sendPacket(sock,cpt,packetLen,fill)
   local bta=btaCreate2(packetLen)
   local ix=encByte(bta,1,cpt)
   ix=encVBInt(bta,ix,packetLen)
   if fill then fill(bta,ix) end
   return sock:write(bta)
end

local function sendConnack(client,reason)
   local sock=client.sock
   if client.version == 5 then
      local propLen=reason == 0 and 2 or 0
      local packetLen=2+encVBInt(nil,0,propLen)+propLen
      return sendPacket(sock,MQTT_CONNACK,packetLen,function(bta,ix)
         ix=encByte(bta,ix,0)
         ix=encByte(bta,ix,reason)
         ix=encVBInt(bta,ix,propLen)
         if propLen > 0 then
            ix=encByte(bta,ix,36) -- Maximum QoS
            encByte(bta,ix,0)
         end
      end)
   end
   return sendPacket(sock,MQTT_CONNACK,2,function(bta,ix)
      ix=encByte(bta,ix,0)
      encByte(bta,ix,reason)
   end)
end

local function sendDisconnect(client,reason)
   if client.version == 5 and client.connected then
      sendPacket(client.sock,MQTT_DISCONNECT,2,function(bta,ix)
         ix=encByte(bta,ix,reason)
         encVBInt(bta,ix,0)
      end)
   end
end

local function cleanupClient(client,why)
   if client.cleaned then return end
   client.cleaned=true
   client.connected=false
   client.subscriptions={}
   local broker=client.broker
   if broker then broker.clients[client]=nil end
   if client.sock then pcall(function() client.sock:close() end) end
   if why then emitError(broker,client,"mqtt",why) end
end

local function protocolError(client,reason)
   sendDisconnect(client,reason or 0x82)
   cleanupClient(client,"protocolerror")
   return nil
end

local function mqttRec(client)
   local sock=client.sock
   local broker=client.broker
   local data,msg,err
   dbg("mqttRec enter",client.clientId or "(pre-connect)",client.recOverflowData and #client.recOverflowData or 0)
   if client.recOverflowData then
      data=client.recOverflowData
      client.recOverflowData=nil
   else
      data=""
   end
   while #data < 2 do
      msg,err=sock:read()
      dbg("mqttRec fixed read",client.clientId or "(pre-connect)",msg and #msg or nil,err)
      if not msg then return nil,err end
      data=data..msg
   end
   local cpt=sbyte(data,1)
   local mult,len,ix,count=1,0,2,0
   while true do
      while #data < ix do
         msg,err=sock:read()
         dbg("mqttRec rem read",client.clientId or "(pre-connect)",msg and #msg or nil,err)
         if not msg then return nil,err end
         data=data..msg
      end
      local digit=sbyte(data,ix)
      len=len+(digit&0x7F)*mult
      ix=ix+1
      count=count+1
      if len > broker.opt.maxPacketSize then return nil,"packetsizelimit" end
      if digit < 0x80 then break end
      if count == 4 then return nil,"malformedremaininglength" end
      mult=mult*0x80
   end
   local bta
   if len > 0 then
      bta=btaCreate(len)
      local have=#data-(ix-1)
      local copyLen=have < len and have or len
      local plen=copyLen
      if copyLen > 0 then btaCopy(bta,1,data,ix,ix+copyLen-1) end
      dbg("mqttRec payload start",client.clientId or "(pre-connect)","cpt",cpt,"len",len,"have",have,"copied",copyLen)
      if have > len then
         client.recOverflowData=ssub(data,ix+len)
         dbg("mqttRec stored overflow",client.clientId or "(pre-connect)",#client.recOverflowData)
      end
      while plen < len do
         data,err=sock:read()
         dbg("mqttRec payload read",client.clientId or "(pre-connect)",data and #data or nil,err)
         if not data then return nil,err end
         local need=len-plen
         local got=#data
         copyLen=got < need and got or need
         if copyLen > 0 then btaCopy(bta,1+plen,data,1,copyLen) end
         plen=plen+copyLen
         if got > need then
            client.recOverflowData=ssub(data,need+1)
            dbg("mqttRec stored overflow",client.clientId or "(pre-connect)",#client.recOverflowData)
            break
         end
      end
   elseif #data >= ix then
      client.recOverflowData=ssub(data,ix)
      dbg("mqttRec stored zero-len overflow",client.clientId or "(pre-connect)",#client.recOverflowData)
   end
   client.lastPacketTime=now()
   dbg("mqttRec return",client.clientId or "(pre-connect)","cpt",cpt,"type",cpt and (cpt & 0xF0),"len",len)
   return cpt,bta
end

local function validTopicName(topic)
   return topic and topic ~= "" and not topic:find("[+#]")
end

local function validTopicFilter(filter)
   if not filter or filter == "" then return nil end
   if filter:sub(1,7) == "$share/" then return nil,"shared" end
   local p=1
   while true do
      local ix=filter:find("#",p,true)
      if not ix then break end
      if ix ~= #filter or (ix > 1 and filter:sub(ix-1,ix-1) ~= "/") then
         return nil
      end
      p=ix+1
   end
   p=1
   while true do
      local ix=filter:find("+",p,true)
      if not ix then return true end
      if (ix > 1 and filter:sub(ix-1,ix-1) ~= "/") or
         (ix < #filter and filter:sub(ix+1,ix+1) ~= "/") then
         return nil
      end
      p=ix+1
   end
end

local function nextLevel(s,ix)
   if ix > #s+1 then return nil,ix,true end
   if ix == #s+1 then return "",ix+1,true end
   local slash=s:find("/",ix,true)
   if slash then return s:sub(ix,slash-1),slash+1,false end
   return s:sub(ix),#s+2,true
end

local function topicMatches(filter,topic)
   local first=filter:sub(1,1)
   if topic:sub(1,1) == "$" and (first == "+" or first == "#") then
      return false
   end
   local fi,ti=1,1
   while true do
      local flev,tlev,fend,tend
      flev,fi,fend=nextLevel(filter,fi)
      tlev,ti,tend=nextLevel(topic,ti)
      if flev == "#" then return true end
      if not flev or not tlev then return flev == tlev end
      if flev ~= "+" and flev ~= tlev then return false end
      if fend and tend then return true end
      if tend and not fend then
         local nf=nextLevel(filter,fi)
         return nf == "#"
      end
      if fend ~= tend then return false end
   end
end

local function encodePublish(sub,topic,payload)
   local ix=encString(nil,1,topic)
   if sub.version == 5 then ix=encVBInt(nil,ix,0) end
   local packetLen=ix-1+#payload
   local bta=btaCreate2(packetLen)
   ix=encByte(bta,1,MQTT_PUBLISH)
   ix=encVBInt(bta,ix,packetLen)
   ix=encString(bta,ix,topic)
   if sub.version == 5 then ix=encVBInt(bta,ix,0) end
   if #payload > 0 then bta[ix]=payload end
   return bta
end

local function localPayload(client,payload)
   if not client.recbta then return payload end
   local bta=btaCreate(#payload)
   if #payload > 0 then bta[1]=payload end
   return bta
end

local function deliverLocal(sub,subInfo,topic,payload)
   local cb=type(subInfo) == "table" and subInfo.onpub or nil
   cb=cb or sub.onpub
   local ok,err=pcall(cb,topic,localPayload(sub,payload),{},MQTT_PUBLISH)
   if not ok then emitError(sub.broker,sub,"onpub",err) end
   return true
end

local function routePublish(client,topic,payload)
   local broker=client.broker
   local dead={}
   for sub in pairs(broker.clients) do
      if sub.connected then
         for filter,subInfo in pairs(sub.subscriptions) do
            if topicMatches(filter,topic) then
               if sub.localClient then
                  deliverLocal(sub,subInfo,topic,payload)
               else
                  if not sub.sock:write(encodePublish(sub,topic,payload)) then
                     tinsert(dead,sub)
                  end
               end
               break
            end
         end
      end
   end
   for _,sub in ipairs(dead) do cleanupClient(sub,"writefailed") end
   return client.connected
end

local function handlePublish(client,bta,cpt)
   if not bta then return protocolError(client) end
   local qos=(cpt>>1)&3
   local retain=(cpt & 1) ~= 0
   if qos ~= 0 then return protocolError(client,0x9B) end
   local topic,ix=decString(bta,1)
   if not validTopicName(topic) then return protocolError(client) end
   if client.version == 5 then
      local propT
      propT,ix=skipProps(bta,ix)
      if not propT then return protocolError(client) end
   end
   local len=btaSize(bta)
   local payload=ix <= len and bta2string(bta,ix,len) or ""
   local onpublish=client.broker.opt.onpublish
   if onpublish then
      local ok,allow=pcall(onpublish,client,topic,payload,retain)
      if not ok then
         emitError(client.broker,client,"onpublish",allow)
         return true
      end
      if allow == false then return true end
   end
   return routePublish(client,topic,payload)
end

local function sendSuback(client,pi,codes)
   local extra=client.version == 5 and 1 or 0
   return sendPacket(client.sock,MQTT_SUBACK,2+extra+#codes,function(bta,ix)
      ix=enc2BInt(bta,ix,pi)
      if client.version == 5 then ix=encVBInt(bta,ix,0) end
      for _,code in ipairs(codes) do ix=encByte(bta,ix,code) end
   end)
end

local function handleSubscribe(client,bta,cpt)
   dbg("SUBSCRIBE enter",client.clientId,"cpt",cpt,"payload",bta and btaSize(bta) or 0)
   if (cpt & 0x0F) ~= 0x02 or not bta then return protocolError(client) end
   local len=btaSize(bta)
   local pi,ix=dec2BInt(bta,1)
   dbg("SUBSCRIBE pi",client.clientId,pi,"ix",ix,"len",len)
   if not pi or pi == 0 then return protocolError(client) end
   if client.version == 5 then
      local propT
      propT,ix=skipProps(bta,ix)
      if not propT then return protocolError(client) end
   end
   local codes,count={},0
   while ix <= len do
      local filter
      filter,ix=decString(bta,ix)
      dbg("SUBSCRIBE filter",client.clientId,filter,"ix",ix)
      if not filter or ix > len then return protocolError(client) end
      local opt
      opt,ix=decByte(bta,ix)
      dbg("SUBSCRIBE opt",client.clientId,opt,"ix",ix)
      if not opt then return protocolError(client) end
      local reqQos=opt & 3
      local accepted,why=validTopicFilter(filter)
      if accepted and client.broker.opt.allowWildcards == false and
         filter:find("[+#]") then
         accepted=false
         why="wildcards"
      end
      if reqQos == 3 or (client.version == 4 and (opt & 0xFC) ~= 0) or
         (client.version == 5 and ((opt & 0xC0) ~= 0 or ((opt>>4)&3) == 3)) then
         accepted=false
      end
      if client.version == 5 and (opt & 0x04) ~= 0 then
         accepted=false
         why="unsupported"
      end
      if accepted then
         client.subscriptions[filter]=true
         codes[#codes+1]=0
      elseif client.version == 5 then
         codes[#codes+1]=why == "shared" and 0x9E or why == "wildcards" and 0xA2 or why == "unsupported" and 0x83 or 0x8F
      else
         codes[#codes+1]=0x80
      end
      count=count+1
   end
   if count == 0 then return protocolError(client) end
   dbg("SUBSCRIBE send suback",client.clientId,"count",count)
   return sendSuback(client,pi,codes)
end

local function sendUnsuback(client,pi,codes)
   local packetLen=client.version == 5 and 3+#codes or 2
   return sendPacket(client.sock,MQTT_UNSUBACK,packetLen,function(bta,ix)
      ix=enc2BInt(bta,ix,pi)
      if client.version == 5 then
         ix=encVBInt(bta,ix,0)
         for _,code in ipairs(codes) do ix=encByte(bta,ix,code) end
      end
   end)
end

local function handleUnsubscribe(client,bta,cpt)
   if (cpt & 0x0F) ~= 0x02 or not bta then return protocolError(client) end
   local len=btaSize(bta)
   local pi,ix=dec2BInt(bta,1)
   if not pi or pi == 0 then return protocolError(client) end
   if client.version == 5 then
      local propT
      propT,ix=skipProps(bta,ix)
      if not propT then return protocolError(client) end
   end
   local codes,count={},0
   while ix <= len do
      local filter
      filter,ix=decString(bta,ix)
      if not filter then return protocolError(client) end
      client.subscriptions[filter]=nil
      codes[#codes+1]=0
      count=count+1
   end
   if count == 0 then return protocolError(client) end
   return sendUnsuback(client,pi,codes)
end

local function handlePingreq(client,bta,cpt)
   if cpt ~= MQTT_PINGREQ or bta then return protocolError(client) end
   return sendPacket(client.sock,MQTT_PINGRESP,0)
end

local function handleDisconnect(client,bta,cpt)
   if cpt ~= MQTT_DISCONNECT then return protocolError(client) end
   if client.version == 5 and bta then
      local ix=1
      if btaSize(bta) >= 1 then ix=2 end
      if ix <= btaSize(bta) then
         local propT
         propT,ix=skipProps(bta,ix)
         if not propT then return protocolError(client) end
      end
   elseif bta then
      return protocolError(client)
   end
   cleanupClient(client)
   return nil
end

local function findExistingClient(broker,clientId)
   for client in pairs(broker.clients) do
      if client.clientId == clientId then return client end
   end
end

local function parseConnect(client,bta,cpt)
   if cpt ~= MQTT_CONNECT or not bta then return nil,"protocolerror" end
   local proto,ix=decString(bta,1)
   local level,flags,keepalive
   if proto ~= "MQTT" then return nil,"unsupported" end
   level,ix=decByte(bta,ix)
   if level ~= 4 and level ~= 5 then
      client.version=4
      return nil,"unsupported"
   end
   client.version=level
   flags,ix=decByte(bta,ix)
   keepalive,ix=dec2BInt(bta,ix)
   if not flags or not keepalive then return nil,"malformed" end
   if (flags & 1) ~= 0 or ((flags>>3)&3) == 3 then return nil,"protocolerror" end
   if (flags & 0x04) == 0 and (flags & 0x38) ~= 0 then return nil,"protocolerror" end
   if (flags & 0x40) ~= 0 and (flags & 0x80) == 0 then return nil,"protocolerror" end
   if (flags & 0x02) == 0 then return nil,"cleansessionrequired" end
   if level == 5 then
      local propT
      propT,ix=skipProps(bta,ix)
      if not propT then return nil,"protocolerror" end
      if propT.sessionexpiryinterval and propT.sessionexpiryinterval ~= 0 then
         return nil,"cleansessionrequired"
      end
      if propT.maximumPacketSize and propT.maximumPacketSize < 1 then
         return nil,"protocolerror"
      end
      if propT.authenticationMethod or propT.authenticationData then
         return nil,"badauth"
      end
   end
   local will=(flags & 0x04) ~= 0
   if will then return nil,"willunsupported" end
   local clientId
   clientId,ix=decString(bta,ix)
   if not clientId then return nil,"malformed" end
   if clientId == "" then
      local broker=client.broker
      broker.nextClientNo=broker.nextClientNo+1
      clientId="mqtt-"..broker.nextClientNo
   end
   local username,password
   if (flags & 0x80) ~= 0 then
      username,ix=decString(bta,ix)
      if not username then return nil,"malformed" end
   end
   if (flags & 0x40) ~= 0 then
      password,ix=decBinData(bta,ix)
      if not password then return nil,"malformed" end
   end
   if ix ~= btaSize(bta)+1 then return nil,"malformed" end
   client.clientId=clientId
   client.keepalive=keepalive
   return true,username,password
end

local function connackFailure(client,err)
   if client.version == 5 then
      local reason=({
         unsupported=0x84, malformed=0x81, protocolerror=0x82,
         cleansessionrequired=0x82, badauth=0x86, unauthorized=0x87,
         willunsupported=0x83
      })[err] or 0x82
      sendConnack(client,reason)
   elseif err == "unauthorized" then
      sendConnack(client,5)
   elseif err == "badauth" then
      sendConnack(client,4)
   elseif err == "malformed" or err == "protocolerror" then
      sendConnack(client,1)
   elseif err == "unsupported" then
      sendConnack(client,1)
   else
      sendConnack(client,1)
   end
end

local function handleConnect(client,bta,cpt)
   local ok,u,p=parseConnect(client,bta,cpt)
   if not ok then
      connackFailure(client,u)
      cleanupClient(client,u)
      return nil
   end
   local broker=client.broker
   local auth=broker.opt.auth
   if auth then
      local aok,allowed=pcall(auth,client,u,p)
      if not aok then
         emitError(broker,client,"auth",allowed)
         allowed=false
      end
      if not allowed then
         connackFailure(client,"unauthorized")
         cleanupClient(client,"unauthorized")
         return nil
      end
   end
   local previous=findExistingClient(broker,client.clientId)
   if previous and previous ~= client then cleanupClient(previous,"clientidreused") end
   if not sendConnack(client,0) then
      cleanupClient(client,"writefailed")
      return nil
   end
   client.connected=true
   dbg("CONNECT accepted",client.clientId,"version",client.version,"keepalive",client.keepalive)
   return true
end

local handlers={
   [MQTT_PUBLISH]=handlePublish,
   [MQTT_SUBSCRIBE]=handleSubscribe,
   [MQTT_UNSUBSCRIBE]=handleUnsubscribe,
   [MQTT_PINGREQ]=handlePingreq,
   [MQTT_DISCONNECT]=handleDisconnect
}

local function clientRun(sock,broker)
   local client={
      sock=sock,broker=broker,version=4,clientId=nil,connected=false,
      keepalive=0,lastPacketTime=now(),subscriptions={},recOverflowData=nil
   }
   broker.clients[client]=true
   dbg("clientRun start")
   local cpt,bta=mqttRec(client)
   if cpt then
      if handleConnect(client,bta,cpt) then
         while client.connected do
            dbg("clientRun waiting",client.clientId)
            cpt,bta=mqttRec(client)
            dbg("clientRun received",client.clientId,cpt,(cpt and bta) and btaSize(bta) or nil)
            if not cpt then
               cleanupClient(client,bta)
               break
            end
            local func=handlers[cpt & 0xF0]
            dbg("clientRun dispatch",client.clientId,cpt & 0xF0,func and "yes" or "no")
            if not func or cpt == MQTT_PUBACK or cpt == MQTT_PUBREC or
               cpt == (MQTT_PUBREL|0x02) or cpt == MQTT_PUBCOMP or
               (cpt & 0xF0) == MQTT_CONNECT then
               protocolError(client)
               break
            end
            if not func(client,bta,cpt) then break end
         end
      end
   else
      cleanupClient(client,bta)
   end
   cleanupClient(client)
end

local function acceptLoop(listener,broker)
   while broker.running do
      local sock=listener:accept()
      if not sock then break end
      sock:event(clientRun,"s",broker)
   end
end

local function queueLocalPublish(client,topic,payload)
   local broker=client.broker
   local head=broker.localQHead
   broker.localQ[head]={client=client,topic=topic,payload=payload}
   broker.localQHead=head+1
   broker.localQElems=broker.localQElems+1
   if broker.localCosock then broker.localCosock:enable() end
end

local function localPublishCosock(sock,broker)
   while true do
      local tail=broker.localQTail
      if broker.localQHead == tail then sock:disable() end
      if not broker.running then return end
      local op=broker.localQ[tail]
      if op then
         broker.localQ[tail]=nil
         broker.localQTail=tail+1
         broker.localQElems=broker.localQElems-1
         if op.client.connected then
            routePublish(op.client,op.topic,op.payload)
         end
      end
   end
end

local LC={}
LC.__index=LC

function LC:publish(topic,msg,opt,prop)
   opt=opt or {}
   if not self.connected then return false end
   if not validTopicName(topic) then return false end
   if opt.qos and opt.qos ~= 0 then return false end
   queueLocalPublish(self,topic,msg or "")
   return self.connected
end

function LC:subscribe(topic,onsuback,opt,prop)
   if type(onsuback) == "table" then
      prop=opt
      opt=onsuback
      onsuback=nil
   end
   opt=opt or {}
   local accepted=validTopicFilter(topic)
   if accepted then
      self.subscriptions[topic]={onpub=opt.onpub}
   end
   if onsuback then pcall(onsuback,topic,accepted and 0 or 0x80,{}) end
   return self.connected and accepted and true or false
end

function LC:unsubscribe(topic,onunsubscribe,prop)
   if self.subscriptions[topic] ~= nil then self.subscriptions[topic]=nil end
   if onunsubscribe then pcall(onunsubscribe,topic,0,{}) end
   return self.connected
end

function LC:disconnect(reason)
   local retv=self.connected
   if self.connected then
      self.disconnected=true
      cleanupClient(self)
      if self.onstatus then
         pcall(self.onstatus,"mqtt","disconnect",{reasoncode=reason or 0,properties={}})
      end
   end
   return retv
end

function LC:close()
   pcall(function() self:disconnect() end)
end

LC.__gc=LC.close
LC.__close=LC.close

function LC:status()
   local broker=self.broker
   return broker and broker.localQElems or 0,self.connected,
          (self.disconnected and true or false)
end

local B={}
B.__index=B

function B:createClient(onstatus,onpub,opt)
   if onstatus ~= nil then chkType("onstatus",onstatus,"function") end
   if type(onpub) == "table" and opt == nil then
      opt=onpub
      onpub=nil
   end
   if onpub ~= nil then chkType("onpub",onpub,"function") end
   opt=opt or {}
   if type(opt) ~= "table" then optErr("opt","table",opt) end
   self.nextClientNo=self.nextClientNo+1
   local client=setmetatable({
      broker=self,
      version=5,
      clientId=opt.clientidentifier or ("local-"..self.nextClientNo),
      connected=true,
      disconnected=false,
      keepalive=0,
      lastPacketTime=now(),
      subscriptions={},
      recOverflowData=nil,
      localClient=true,
      onstatus=onstatus,
      onpub=onpub or defaultOnpub,
      recbta=opt.recbta ~= false
   },LC)
   self.clients[client]=true
   if onstatus then
      pcall(onstatus,"mqtt","connect",{
         sessionpresent=false,
         reasoncode=0,
         properties={}
      })
   end
   return client
end

function B:close()
   self.running=false
   if self.timer then self.timer:cancel(); self.timer=nil end
   if self.listeners then
      for _,lst in ipairs(self.listeners) do
         if lst.listener then lst.listener:close() end
      end
      self.listeners=nil
   end
   self.listener=nil
end

function B:shutdown()
   self:close()
   local clients={}
   for client in pairs(self.clients) do clients[#clients+1]=client end
   for _,client in ipairs(clients) do cleanupClient(client,"shutdown") end
end

function B:status()
   local count=0
   local listeners={}
   for _ in pairs(self.clients) do count=count+1 end
   for _,lst in ipairs(self.listeners or {}) do
      listeners[#listeners+1]={
         port=lst.port,
         tls=lst.tls,
         address=lst.address
      }
   end
   return {
      running=self.running,
      clients=count,
      port=self.port,
      ports=self.ports,
      listeners=listeners,
      maxPacketSize=self.opt.maxPacketSize
   }
end

local function scanKeepalive(broker)
   local ts=now()
   local dead={}
   for client in pairs(broker.clients) do
      if client.connected and client.keepalive and client.keepalive > 0 then
         if ts-client.lastPacketTime > (client.keepalive*3)//2 then
            dead[#dead+1]=client
         end
      end
   end
   for _,client in ipairs(dead) do cleanupClient(client,"keepalivetimeout") end
   return broker.running
end

local function create(port,options)
   if type(port) == "table" and options == nil then
      options=port
      port=options.port
   end
   options=options or {}
   if type(options) ~= "table" then optErr("options","table",options) end
   port=port or options.port or (options.shark and 8883 or 1883)
   if type(port) ~= "number" then optErr("port","number",port) end
   if options.plainPort ~= nil and type(options.plainPort) ~= "number" then
      optErr("options.plainPort","number",options.plainPort)
   end
   if options.auth ~= nil then chkType("options.auth",options.auth,"function") end
   if options.onerror ~= nil then chkType("options.onerror",options.onerror,"function") end
   if options.onpublish ~= nil then chkType("options.onpublish",options.onpublish,"function") end
   if options.allowWildcards ~= nil and type(options.allowWildcards) ~= "boolean" then
      optErr("options.allowWildcards","boolean",options.allowWildcards)
   end
   if options.maxPacketSize ~= nil and type(options.maxPacketSize) ~= "number" then
      optErr("options.maxPacketSize","number",options.maxPacketSize)
   end
   local opt={
      address=options.address,
      port=port,
      plain=options.plain,
      plainPort=options.plainPort,
      backlog=options.backlog,
      shark=options.shark,
      timeout=options.timeout or 5000,
      maxPacketSize=options.maxPacketSize or 262144,
      allowWildcards=options.allowWildcards ~= false,
      auth=options.auth,
      onpublish=options.onpublish,
      onerror=options.onerror
   }
   local broker=setmetatable({
      listener=nil,listeners={},opt=opt,clients={},timer=nil,nextClientNo=0,
      running=true,port=port,ports={},
      localQ={},localQHead=1,localQTail=1,localQElems=0,localCosock=nil
   },B)
   local function bind(port,tls,shark)
      local bindOpt={}
      if opt.address then bindOpt.intf=opt.address end
      if shark then bindOpt.shark=shark end
      local listener,err=ba.socket.bind(port,bindOpt)
      if not listener then return nil,err end
      listener:event(acceptLoop,"r",broker)
      broker.listeners[#broker.listeners+1]={
         listener=listener,
         port=port,
         tls=tls and true or false,
         address=opt.address
      }
      broker.ports[#broker.ports+1]=port
      broker.listener=broker.listener or listener
      return listener
   end
   local listener,err=bind(port,opt.shark ~= nil,opt.shark)
   if not listener then return nil,err end
   if opt.shark and opt.plain then
      local plainPort=opt.plainPort or 1883
      if plainPort ~= port then
         listener,err=bind(plainPort,false,nil)
         if not listener then
            broker:close()
            return nil,err
         end
      end
   end
   broker.localCosock=ba.socket.event(localPublishCosock,broker)
   broker.timer=ba.timer(function() return scanKeepalive(broker) end)
   broker.timer:set(1000)
   return broker
end

return {
   create=create
}
