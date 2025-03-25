
-- Builds a single AVP (Attribute-Value Pair)
-- attrType is the numeric ID (e.g., 1 = User-Name, 2 = User-Password)
-- value is a string or byte string representing the value
local function buildAVP(attrType, val)
   local len = #val + 2            -- Total length: type(1 byte) + length(1 byte) + value
   return string.char(attrType) .. string.char(len) .. val
end

-- Pads the password to a multiple of 16 bytes (per RADIUS spec)
local function padPassword(password)
   local padLen = 16 - (#password % 16)
   return password .. string.rep("\0", padLen)   -- Append null bytes
end

-- XORs two strings byte by byte
-- Used to obfuscate password using MD5 hash of sharedSecret + Request Authenticator
local function xorStrings(a, b)
   local result = {}
   for i = 1, #a do
      result[i] = string.char(string.byte(a, i) ~ string.byte(b, i)) -- Bitwise XOR
   end
   return table.concat(result)
end

-- Obfuscates password using MD5 per RFC 2865 Section 5.2
-- password: plain text
-- secret: shared secret
-- authenticator: 16-byte random nonce
-- MD5-based RADIUS password encoding, supporting up to 128-byte passwords
-- Password is obfuscated in 16-byte blocks as per RFC 2865 Section 5.2
local function encodePassword(password, secret, requestAuthenticator)
   local padded = padPassword(password)  -- Pad password to 16-byte boundary
   local result = {}
   local prev = requestAuthenticator     -- First MD5 input uses the Request Authenticator
   for i = 1, #padded, 16 do
      local pBlock = padded:sub(i, i + 15)  -- Next 16-byte plaintext password block
      -- XOR password block with MD5 result
      local c = xorStrings(pBlock, ba.crypto.hash"md5"(secret)(prev)(true))
      table.insert(result, c)
      prev = c  -- Chain next hash: MD5(secret + prev_cipher_block)
   end
   return table.concat(result)
end

local radius={}

-- Main function: send an Access-Request and wait for response (blocking, designed for LSP pages)
-- username and password are provided by the user
local function login(self, username, password)
   trace(username, password)
   local sock = ba.socket.udpcon(self.radiusServerIP,self.radiusServerPort)
   local id = ba.rnds(1)   -- Random request ID (1 byte)
   local authenticator = ba.rndbs(16)   -- 16-byte random nonce
   -- Create AVPs
   local avps = {
      buildAVP(1, username),  -- Type 1: User-Name
      buildAVP(2, encodePassword(password, self.sharedSecret, authenticator))  -- Type 2: User-Password
   }
   -- Assemble packet
   local payload = table.concat(avps)    -- All AVPs concatenated
   local length = 20 + #payload          -- 20-byte RADIUS header + AVPs
   local header = string.char(1, id)     -- Code = 1 (Access-Request), Identifier = random
                 .. ba.socket.h2n(2, length)     -- Big-endian 2-byte length
                 .. authenticator        -- 16-byte Request Authenticator
   local packet = header .. payload      -- Full packet to send

   -- Send UDP packet to RADIUS server
   sock:write(packet)

   -- Wait for response (3-second timeout shown here)
   local data,err = sock:read(3000)    -- Blocks for 3 seconds max
   if not data then
      return false,"socket err: "..tostring(err)
   end

   -- Parse response
   local code = string.byte(data, 1)    -- First byte is the response code
   if code == 2 and #data >= 20 then
      -- Accepted, but let's verify response data
      local respauth = data:sub(5, 20)   -- 16-byte Response Authenticator
      local attrs = data:sub(21)          -- Remaining bytes (Attributes)
      -- Compute expected authenticator
      -- hash arg below is: code .. id .. length .. authenticator .. attrs .. sharedSecret
      local expected = ba.crypto.hash"md5"(data:sub(1,4) .. authenticator .. attrs .. self.sharedSecret)(true)
      if expected == respauth then return true end
      return false, "Invalid RADIUS response hash"
   elseif code == 3 then
      return false, "Access-Reject"
   else
      return false, "Unexpected RADIUS code: "..tostring(code)
   end
end

local radius={login=login}
radius.__index=radius

local function create(radiusServerIP,radiusServerPort,sharedSecret)
   local self={
      radiusServerIP=radiusServerIP,
      radiusServerPort=radiusServerPort,
      sharedSecret=sharedSecret,
   }
   return setmetatable(self, radius)
end

return {create=create}
