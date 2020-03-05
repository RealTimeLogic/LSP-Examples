<?lsp

local wikidata=request:data"data"
if wikidata then
   local su=require"sqlutil"
   local env,conn=su.open"wiki"
   local sql=string.format("INSERT INTO wiki (relpath,data) VALUES(%s,%s)",
                           luasql.quotestr(relpath), -- relpath set by wikifunc
                           luasql.quotestr(wikidata))
   local ok,err=conn:execute(sql)
   su.close(env,conn)
   if ok then
      response:sendredirect(request:url())
   end
   response:senderror(500,err)
   return
end

?>
<html>
  <head>
    <style>
      textarea {
        width:100%;
        height:300px;
      }
    </style>
  </head>
  <body>
    <h1>Create New Wiki Page</h1>
    <form method="post">
      <textarea name="data"></textarea>
      <input type="submit" />
    </form>
  </body>
</html>
