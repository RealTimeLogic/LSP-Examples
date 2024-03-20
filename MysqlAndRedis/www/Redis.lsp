<pre>
<?lsp


local function redisTest()

   local redis = require "resty.redis"
   local red = redis:new()

   red:set_timeout(1000) -- 1 sec

   local ok, err = red:connect("localhost", 6379)
   if not ok then
      print("failed to connect: ", err)
      return
   end

   ok, err = red:set("dog", "an animal")
   if not ok then
      print("failed to set dog: ", err)
      return
   end

   print("set result: ", ok)

   local res, err = red:get("dog")
   if not res then
      print("failed to get dog: ", err)
      return
   end

   if res == ngx.null then
      print("dog not found.")
      return
   end

   print("dog: ", res)

   red:init_pipeline()
   red:set("cat", "Marry")
   red:set("horse", "Bob")
   red:get("cat")
   red:get("horse")
   local results, err = red:commit_pipeline()
   if not results then
      print("failed to commit the pipelined requests: ", err)
      return
   end

   for i, res in ipairs(results) do
      print("type(res)",type(res))
      if type(res) == "table" then
         if not res[1] then
            print("failed to run command ", i, ": ", res[2])
         else
            -- process the table value
         end
      else
         -- process the scalar value
         print(">",res)
      end
   end

   -- Close the connection:
   local ok, err = red:close()
   if not ok then
      print("failed to close: ", err)
      return
   end


end


redisTest() -- Run using blocking socket calls

-- Run as "Non Blocking Sockets" (OpenResty compat cosocket)
print=_G.print -- Redirect LSP print to global (console) print
ba.socket.event(redisTest)

?>
</pre>

