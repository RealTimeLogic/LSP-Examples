-- Designed only to satisfy MySQL.lua.
local M={KEY_TYPE={PKCS8=true},PADDING={RSA_PKCS1_OAEP_PADDING=true}}
local mt={__index=M}
function M:new(opt) return setmetatable({opt=opt}, mt) end
function M:encrypt(data)
   local o=self.opt
   local enc,err = ba.crypto.sign(data,o.public_key,{padding="oaep",hash="sha1",})
   return enc,err
end
return M
