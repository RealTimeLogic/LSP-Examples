<?lsp local function emitForm() ?>
<div id="form">
<p>Enter new message:</p>
<form method="post">
  <textarea name="msg"></textarea>
  <br/><input type="submit"/>
</form>
</div>
<?lsp end ?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<title>SQLite and Lua Tutorial</title>
<link rel="stylesheet" href="style.css" />
</head>
<body>
<?lsp
  local su=require"sqlutil"
  local data=request:data()
  if data.msg then
     -- Quote and prevent SQL injection by escaping '
     local msg=luasql.quotestr(data.msg)
     local sql=string.format("INSERT INTO messages (msg) values(%s)",msg)
     local env,conn = su.open"file"
     local ok,err = conn:execute(sql) -- Insert msg into database
     su.close(env,conn)
     msg = err and fmt("Operation failed: %s",err) or "Message inserted"
     response:write("<p>",msg,"</p>")
     response:write("<p><a href='",request:uri(),"'>Continue</a></p>")
  else
     local function execute(cur)
        local key,msg = cur:fetch()
        while key do
           response:write('<div><h3>Message ',key,'</h3>',msg,'</div>')
           key,msg = cur:fetch()
        end
        return true
     end
     local function opendb() return su.open"file" end
     response:write"<div class='messages'>"
     local ok,err=su.select(opendb,"key,msg FROM messages", execute)
     if not ok then response:write("DB err: "..err) end
     response:write"</div>"
     emitForm()
  end
?>
</body>
</html>
 
