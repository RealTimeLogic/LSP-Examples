<?lsp

-- Using the session to hold variables between pages
local session = request:session(true)
local newvar = 12
newvar = 99
session.holdnewvar = newvar

-- Using the command environment to hold variables between pages.
-- http://barracudaserver.com/ba/doc/?url=en/lua/lua.html#CMDE
myvar=123456


trace("--------------\nIn first: holdnewvar", session.holdnewvar)
trace("In first: myvar", myvar,"\n")


response:forward".second.lsp"

assert(nil,"This code line will not run")

?>
