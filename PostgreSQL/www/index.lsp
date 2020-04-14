<?lsp

--[[
The ephemeral request/response aka command object is valid for the
duration of the HTTP request thus it cannot be used by another
thread. However, we can convert the response to a deferred response,
which can be used by another thread.

Details:
https://realtimelogic.com/ba/doc/?url=lua.html#response_deferred
https://realtimelogic.com/ba/doc/?url=lua.html#CMDE
--]]

local response = response:deferred()


-- Override the default print function, which uses the ephemeral
-- request/response
local function print(...) response:write(...) end

-- The following trick makes it possible to use the LSP tags via the
-- deferred response. LSP data is emitted by using function _emit
_emit=print

-- Check if a table exists in the SQL database
local function tabExists(conn,tabname)
   local res=conn:exec("SELECT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = '"..tabname.."')")
   return res[1].exists == 't'
end

-- This function is run in the context of a thread:
-- https://realtimelogic.com/ba/doc/?url=auxlua.html#thread_lib
local function run(conn, message)
   if not tabExists(conn, 'messages') then
      conn:exec"CREATE TABLE messages (ts TIMESTAMP, msg TEXT)"
      print"<div class='alert alert-info'><strong>Table 'messages' created!</strong></div>"
   end
   if message then
      conn:execParams("INSERT INTO messages(ts, msg) VALUES(NOW(), $1::text)",message)
   end
?>
<table class="table table-striped table-bordered">
  <thead class="thead-dark"><tr><th>Date</th><th>Message</th></tr></thead>
  <tbody class="devtab">
<?lsp
   local res=conn:exec"SELECT TO_CHAR(ts,'HH12:MI:SS MON-DD-YY') date,msg FROM messages"
   for tuple in res:tuples() do
      print("<tr><td>",tuple.date,"</td><td>",tuple.msg,"</td></tr>")
   end
   print'</tbody></table></div></body></html>'
   response:close()
end
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>PostgreSQL Test Page</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
</head>
<body>
<div class="jumbotron text-center">
  <h1>PostgreSQL Test Page</h1>
</div>
<div class="container">
<div class="form-group">
  <form method="post">
    <textarea class="form-control" rows="5" name="comment"></textarea>
    <input type="submit" class="btn btn-primary" value="Save Message"/>
  </form>
</div>
<?lsp 

-- Defer execution of function 'run' -> send to thread lib. See the
-- .preload script for details.
app.pg.run(run, request:data"comment")

?>

