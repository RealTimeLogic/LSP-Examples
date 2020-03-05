<?lsp

-- See .preload for implementation of dbexec, getexconn, and openconn.

-- Manage HTTP POST and return (exit) LSP page
if request:method() == "POST" then
   local url=request:url() -- Full page URL
   local data=request:data() -- Fetch POSTed data
   local conn,env = app.getexconn() -- Exclusive DB write connection obj

   --Note that the doit function below executes in the context of the
   --thread created in the .preload script and not in the context of
   --the LSP page. We can for this reason not use the LSP page's
   --response object since the LSP page is no longer active when the
   --doit function runs. One way to produce a response from another
   --thread than the LSP page is to extract and use the deferred
   --response object.
   local dresp=response:deferred() -- Convert response to a deferred response

   -- The 'doit' function is executed in the context of the thread created in .preload
   -- Note: we can have many concurrent doit functions queued, but
   -- only one can execute at a time.
   local function doit()
      -- Perform DB write (insert) in context of the exclusive DB write thread
      local ok,err = conn:execute(string.format("INSERT INTO list (element) VALUES (%s)",
                                                env.quotestr(data.element)))
      page.commitcnt = page.commitcnt and page.commitcnt+1 or 1
      -- The BUSY will not be here, but in function commit() in .preload.
      trace(string.format("In doit %u, status: %s",page.commitcnt, ok and "OK" or err))

      -- We are in a POST request. Redirect back to the same page and
      -- make browser perform a HTTP GET request.
      -- The following code performs the same as the
      -- standard response:sendredirect() method.
      -- https://en.wikipedia.org/wiki/HTTP_302
      -- Note: The deferred response is a limited version of the
      -- standard response object. See:
      -- https://realtimelogic.com/ba/doc/en/lua/lua.html#defresp
      dresp:setstatus(302)
      if data.auto then url = url.."?auto=" end
      dresp:setheader("Location",url)
      dresp:setcontentlength(0) -- No data, only HTTP header.
      dresp:close() -- Commit response
   end
   app.dbexec(doit) -- Execute 'doit' in the context of the thread used for DB write.
   return -- Exit LSP page
end


-- else HTTP GET: Produce LSP response and emit DB content.


?>
<!DOCTYPE html>
<html>
<head>
<title>DB test</title>
<script src="/rtl/jquery.js" type="text/javascript"></script>
</head>
<body>

<h1>Add Data:</h1>

<form method="POST">
  <input style="width:100%" type="text" name="element" value=""><br>
  <input type="submit" value="Submit">
</form>

<h1>DB Content:</h1>
<ul>
<?lsp

-- Create a new DB connection object and use the object for reading
local conn = app.openconn()
while true do
   local cur,err=conn:execute"SELECT id,element FROM list ORDER BY id DESC LIMIT 400"
   if cur then
      local id,element=cur:fetch()
      while id do
         response:write("<li>",id," : ", element,"</li>")
         id,element=cur:fetch()
      end
      break
   else
      trace("SELECT failed:",err)
      if err == "BUSY" then
         trace"\tWe will continue until it works"
      else
         break
      end
   end
end

conn:close() -- Remember to close the 'read' DB connection object
?>
</ul>

<?lsp if request:data"auto" then ?>
<script>
// We use JQuery for the auto HTML form submit/post
$(function() {
    var d=new Date();
    $("form > input[type=text]").val(d.toUTCString()+" : "+d.getMilliseconds());
    $("form").submit();
});
</script>
<?lsp end ?>

</body>
</html>
