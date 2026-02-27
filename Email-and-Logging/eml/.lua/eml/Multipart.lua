
--------------------------------------------------------------------------------
-- MIMEMultipart
--------------------------------------------------------------------------------

local _M={}

local self = setmetatable( _M, {} )
local meta = getmetatable( self )

local function ReadBoundary( aHeader )
   local aType = aHeader[ 'content-type' ] or {}
   local aParameter = aType.parameter or {}
   local aBoundary = aParameter[ 'boundary' ]
   
   return aBoundary
end

local function ReadMultipart( aValue, aBoundary )
   local MIME = require( 'eml/Decoder' )
   local aMultipart = { boundary = aBoundary }
   local aBoundary = '--' .. aBoundary
   local aLength = aBoundary:len()
   local aStart = 1
   local anEnd = nil
   
   while true do
      aStart = aValue:find( aBoundary, aStart, true )
      
      if aStart then
         aStart = aStart + aLength
         anEnd = aValue:find( aBoundary, aStart, true )
         
         if anEnd then
            aStart = aValue:find( '\n', aStart, true ) + 1

            -- MIME() receives LF-normalized input, so strip only the single
            -- LF that precedes the next boundary marker.
            aMultipart[ #aMultipart + 1 ] = MIME( aValue:sub( aStart, anEnd - 2 ) )
         else
            break
         end
      else
         break
      end
   end
   
   return aMultipart
end

local function NewMultipart( aValue, aHeader )
   local aMultipart = nil
   
   if type( aValue ) == 'table' then
      aMultipart = ReadMultipart( WriteMultipart( aValue ), aValue.boundary )
   else
      aMultipart = ReadMultipart( tostring( aValue or '' ), ReadBoundary( aHeader ) )
   end
   
   setmetatable( aMultipart, self )
   
   return aMultipart
end

function meta:__call( aValue, aHeader )
   return NewMultipart( aValue, aHeader )
end

function self:__concat( aValue )
   return tostring( self ) .. tostring( aValue )
end

function self:__tostring()
   return 'WriteMultipart' --WriteMultipart( self )
end

return _M
