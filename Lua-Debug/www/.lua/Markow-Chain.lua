--[[

The following Lua code is a copy of:
https://embedded-app-server.info/Lua-Coroutines.lsp#MarkovChain

Set a breakpoint on line 46 and resume (F5). See comments below
for more information.

--]]

-- Download data from:
local url='https://realtimelogic.com/articles/Lua-FastTracks-Embedded-Web-Application-Development'

function allwords() -- Modified: fetches data from 'url'

   -- Function mako.sharkclient() is a Lua function in the Mako
   -- Server's Lua startup code. You can step into this function, but you
   -- cannot change the code since the code is inside mako.zip.

   local http = require"httpc".create{shark=mako.sharkclient()}
   http:request{url=url,method="GET"}
   local data,err=http:read"*a"
   if not data then
      trace("HTTP failed:",err)
      return function() return nil end
   end

   -- The 'words' function is run a coroutine. Notice that the "CALL
   -- STACK" is different when halting the code inside the
   -- coroutine. To step out of the coroutine, click 'step into' (F11)
   -- on the code line below with coroutine.yield()
   local function words()
      for word in data:gmatch"%w+" do
         if #word > 2 then coroutine.yield(word) end -- skip short words
      end
   end
   local nextword = coroutine.create(words)
   return function()
       -- 1: Set a breakpoint on the line below.
       -- 2: Resume (F5)
       -- 3: Remove the breakpoint when the line is hit
       -- 4: Take note of the "CALL STACK" before stepping in. The
       --    stack will change to the coroutine stack as soon as you step
       --    into the coroutine
       -- 5: Press F11 to step into the coroutine
      local ok,word=coroutine.resume(nextword)
      return ok and word -- or return nil i.e. end of string
   end
end

function prefix (w1, w2)
   return w1 .. ' ' .. w2
end

local statetab

function insert (index, value)
   if not statetab[index] then
      statetab[index] = {n=0}
   end
   table.insert(statetab[index], value)
end

local function run(prnt)

   local print = prnt or print -- prnt set if called from index.lsp

   -- Follow the debug testing instructions at the top of this file

   local N  = 2
   local MAXGEN = 10000
   local NOWORD = "\n"
   
   -- build table
   statetab = {}
   local w1, w2 = NOWORD, NOWORD
   for w in allwords() do
      insert(prefix(w1, w2), w)
      w1 = w2; w2 = w;
   end
   insert(prefix(w1, w2), NOWORD)
   -- generate text
   w1 = NOWORD; w2 = NOWORD     -- reinitialize
   for i=1,MAXGEN do
      local list = statetab[prefix(w1, w2)]
      -- choose a random item from list
      local r = math.random(#list)
      local nextword = list[r]
      if nextword == NOWORD then return end
      print(nextword)
      w1 = w2; w2 = nextword
   end
end

return {
   run=run
}
