
-- Mapping of QNX PPS messaging and SMQ
-- http://www.qnx.com/developers/docs/7.0.0/#com.qnx.doc.pps.developer/topic/about.html
-- https://realtimelogic.com/ba/doc/?url=SMQ.html


local tinsert,fmt=table.insert,string.format

-- Table with function names equal the :encoding: as specified here:
-- http://www.qnx.com/developers/docs/7.0.0/#com.qnx.doc.pps.developer/topic/objects_attribute_syntax.html
local decodeT={
   n=function(v) return tonumber(v) end,
   b=function(v) return v=="true" end,
   b64=function(v) return ba.b64decode(v) end,
   json=function(v) return ba.json.decode(v) end,
}

-- Convert a PPS key/val data packet to a Lua table
local function decode(data)
   local tab={}
   -- iterate each line in the data packet
   for line in data:gmatch"%s*([^%s]+)\n" do
      -- attrname:encoding:value
      local key,enc,val=line:match"([^:]+):([^:]*):(.+)"
      if key and val then -- Skip lines not matching
         local conv=decodeT[enc] -- Find :encoding: func
         -- Convert using :encoding: func or use value 'as is' if not found
         if conv then tab[key] = conv(val) else tab[key] = val end
      end
   end
   return tab
end

-- Table with functions for converting Lua values to PPS values
local encodeT={
   number=function(v) return 'n:'..tostring(v) end,
   boolean=function(v) return 'b:'..(v==true and "true" or "false") end,
   string=function(v)
             if v:find"[^%g]" then return 'b64:'..ba.b64encode(v) end
             return ":"..v
          end,
   table=function(v) return 'json:'..ba.json.encode(v) end,
}

-- Convert a Lua table to PPS key/val data
local function encode(tab)
   local data={}
   for key,val in pairs(tab) do
      local conv=encodeT[type(val)]
      tinsert(data,fmt("%s:%s", key, conv and conv(val) or ":"..tostring(val)))
   end
   return table.concat(data,"\n")
end

-- PPS pipe running as a cosocket. Function reads from pipe, converts
-- the data to a Lua table, and publishes the data using SMQ.
local function onPpsMsg(fp, self, topic, cb)
   local smq=self.smq
   local topT=self.topicsT[topic]
   topT.fp=fp
   while true do
      local data=fp:read()
      if not data then break end
      local tab=decode(data)
      topT.msg=tab
      cb(true,tab,data)
      smq:publish(tab, topic)
   end
   self.topicsT[topic]=nil
   smq:unsubscribe(topic)
end

-- SMQ 'subscribe' callback. Function converts the received Lua table
-- to PPS data and publishes the data using the PPS 'topic'
local function onSmqMsg(self,tab,ptid,tid,subtid, cb)
   if ptid == 1 then return end -- If publishing to self i.e. onPpsMsg called
   local smq=self.smq
   local topic = tid == 1 and smq:tid2subtopic(subtid) or smq:tid2topic(tid)
   local topT=self.topicsT[topic]
   topT.msg=tab
   local data=encode(tab)
   cb(false,tab,data)
   topT.fp:write(data) -- PPS publish
end

local function noop() end -- Do nothing

local P={} -- PPS
P.__index=P -- https://www.lua.org/pil/16.2.html

function P:subscribe(topic, delta, cb)
   assert(not self.topicsT[topic], "Already subscribed")
   assert(not cb or type(cb) == "function")
   cb = cb or noop
   local smq=self.smq
   self.topicsT[topic] = {}
   local tname = delta == true and topic.."?delta" or topic
   local fp,err=ba.pipe.open(tname, onPpsMsg, self, topic, cb)
   if not fp then
      self.topicsT[topic]=nil
      return nil,err
   end
   local function onmsg(tab,ptid,tid,subtid) -- closure
      onSmqMsg(self,tab,ptid,tid,subtid,cb)
   end
   smq:subscribe(topic, {json=true,onmsg=onmsg})
   smq:subscribe("self",{json=true,onmsg=onmsg, subtopic=topic})
   return true,fp
end

local function onLastPps(self,data,ptid)
   local topT=self.topicsT[data] -- data payload is the requested topic
   if topT and topT.msg then
      self.smq:publish(topT.msg, ptid, data) 
   end
end

local function create(op)
   local smq = require"smq.hub".create(op)
   local self={
      topicsT={}, -- subscribed, where k=topic,v={fp=pipe,msg=last-msg}
      smq=smq
   }
   smq:subscribe("self", {
                    subtopic="last-pps",
                    onmsg=function(data,ptid) onLastPps(self,data,ptid) end
                 })
   return setmetatable(self,P), smq
end

return {create=create}
