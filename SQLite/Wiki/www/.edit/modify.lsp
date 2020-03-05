<?lsp


local newdata=request:data"data"
if newdata then -- If user submits data using form below
   local su=require"sqlutil"
   local env,conn=su.open"wiki"
   local sql=string.format("UPDATE wiki SET data=%s WHERE relpath=%s",
                           luasql.quotestr(newdata),
                           luasql.quotestr(relpath)
                        )
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
    <h1>Modify Wiki Page</h1>
    <?lsp=app.text2html(wikidata)?>
    <form method="post">
      <textarea name="data"><?lsp=wikidata?></textarea>
      <input type="submit" />
    </form>
  </body>
</html>
