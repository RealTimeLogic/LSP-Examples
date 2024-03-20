local M={}
local mt={__index=M}
function M.new() return setmetatable({ctx=ba.crypto.hash"sha256"}, mt) end
function M:update(s) return self.ctx(s) end
function M:final() return self.ctx(true,"binary") end
function M:reset() self.ctx=ba.crypto.hash"sha256" end
return M
