<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>MySQL Driver Test</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
<main>
<h1>MySQL Driver Test</h1>
<p>This page runs the MySQL driver test against the local database configured in the example.</p>
<pre>
<?lsp

local function mySqlTest()
   local mysql = require "resty.mysql"
   local db = mysql:new()
   local cfg={
      host = "localhost",
      port = 3306,
      database = "world",
      user = "root",
      password = "qwerty"
   }
   local ok, err, errno, sqlstate = db:connect(cfg)
   if not ok then
      print("cannot connect",err, errno, sqlstate)
      return
   end

   local res, err, errno, sqlstate =
      db:query("select * from Persons order by PersonID limit 50", 50)
   if not res then
      print("bad result #1: ", err, ": ", errno, ": ", sqlstate, ".")
      return
   end

   for _, row in ipairs(res) do
      for k, v in pairs(row) do
         print('>',k,v)
      end
   end

   db:close()
end


mySqlTest() -- Run using blocking socket calls

-- Run as "Non Blocking Sockets" (OpenResty compat cosocket)
print=_G.print -- Redirect LSP print to global (console) print
ba.socket.event(mySqlTest)

?>
</pre>
</main>
</body>
</html>
