
local _ENV = setmetatable({},{__index=_G})

function hello(env)
   local _ENV = env or _ENV
   local msg = "Hello World 2. _ENV ="
   print(msg,_ENV)
   trace(msg,_ENV)
end

return _ENV
