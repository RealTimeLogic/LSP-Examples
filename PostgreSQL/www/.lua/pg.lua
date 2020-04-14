
local pg = require "pgsql"

local function wait4conn(self)
   local reset=false
   while self.conn:status() ~= pg.CONNECTION_OK and self.run == true and self.closed == false do
      trace("Resetting pgsql connection", self.conn)
      self.conn:reset()
      reset=true
   end
   return reset
end

local function connect(self,cinfo,callback)
   if type(cinfo) == 'table' then
      cinfo = string.format("host=%s port=%d user=%s password=%s",
                            cinfo.host,cinfo.port,cinfo.user,cinfo.password)
   end
   self.conn = pg.connectdb(cinfo)
   self.run = self.conn:status() == pg.CONNECTION_OK
   self.time = os.time()
   if callback then callback(self.conn) end
end

local function action(self, runCB, ...)
   if not self.run then
      trace"Attempting to use closed pgsql connection"
      return
   end
   if (os.time() - self.time) > 60 then
      self.conn:exec"SELECT 1" -- Ping
   end
   if self.conn:status() ~= pg.CONNECTION_OK then
      wait4conn(self)
   end
   local runagain = runCB(self.conn, ...)
   while wait4conn(self) and runagain do
      runagain = runCB(self.conn, ...)
   end
   self.time = os.time()
end

local function close(self)
   if self.run then
      self.run=false
      self.conn:finish()
   end
end


local function create(cinfo, callback)
   local self={run=false,closed=false}
   local dbthread=ba.thread.create()
   if type(callback) == 'function' then
      dbthread:run(function() connect(self,cinfo,callback) end)
   else
      connect(self,cinfo) -- Blocking connect call
   end
   return {
      conn=self.conn, -- Set if 'Blocking'
      connected=function() return self.conn and self.conn:status() ~= pg.CONNECTION_OK end,
      run=function(runCB, ...)
             local t=table.pack(...)
             dbthread:run(function() action(self, runCB, table.unpack(t)) end)
          end,
      close=function() dbthread:run(function() close(self) end) self.closed = true end
   }
end

return {create=create}
