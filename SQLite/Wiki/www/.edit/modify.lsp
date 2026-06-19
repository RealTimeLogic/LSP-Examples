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
    <title>Modify Wiki Page</title>
    <link rel="stylesheet" href="../style.css">
  </head>
  <body>
    <main>
      <h1>Modify Wiki Page</h1>
      <?lsp=app.text2html(wikidata)?>
      <form method="post">
        <textarea name="data"><?lsp=wikidata?></textarea>
        <input type="submit" value="Save changes" />
      </form>
    </main>
  </body>
</html>
