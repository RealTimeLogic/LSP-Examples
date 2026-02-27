<pre>
<?lsp

local function a()
   if mako.daemon then
      error"This code is designed to crash. You chould receive an email with the stack trace."
   else
      print(debug.traceback"The server is not running in the background")
   end
end

local function b()
   a()
end

b()

?>
</pre>
