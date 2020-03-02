<?lsp
   response:setheader("Content-type","application/octet-stream")
   response:setheader(
     "Content-Disposition","attachment; filename=\"ajax.lsp\"")
   response:setheader(
     "Cache-Control","no-store, no-cache, no-transform, must-revalidate, private")
   response:setheader("Pragma","private")
   response:setheader("Expires","0")
response:write[[

<?lsp
if request:header"x-requested-with" then
   local key=request:data"key"
   if key then
      local resp
      key=tonumber(key)
      if key and key >=32 and key <= 127 then
         resp=string.char(key)
      else
         resp = key and string.format(' "%d" ',key) or '?'
      end
      trace(resp)
      response:json({char=resp})
   end
end
?>
<html>
<head>
<script src="/rtl/jquery.js"></script>
<script>
$(function() {
   $("#out").empty();
   $("#in").keypress(function(ev) {
      $.getJSON(window.location,{key:ev.which}, function(rsp) {
         $("#out").append(rsp.char);
      });
   });
});
</script>
</head>
<body>
<h1 id="out">hello</h1>
<input id="in" type="text" />
</body>
</html>


]]
   

?>
