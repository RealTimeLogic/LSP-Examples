<?lsp

local session = request:session()
trace("In second: holdnewvar", session.holdnewvar)
trace("In second: myvar", myvar,"\n")

print(session.holdnewvar) -- Will not print since we forward
response:forward".third.lsp"

?>
