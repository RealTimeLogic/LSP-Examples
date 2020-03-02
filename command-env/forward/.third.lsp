<pre>
<?lsp


-- Your solution, which works
local session = request:session()
trace("In third: holdnewvar", session.holdnewvar)
trace("In third: myvar", myvar,"\n")
print("In third: holdnewvar", session.holdnewvar)
print("In third: myvar", myvar)



?>
</pre>
