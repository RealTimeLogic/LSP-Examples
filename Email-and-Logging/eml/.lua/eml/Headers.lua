--------------------------------------------------------------------------------
-- MIMEHeaders
--------------------------------------------------------------------------------

local _M={}

local self = setmetatable( _M, {} )
local meta = getmetatable( self )

local function ReadHeaders( aValue )
    local MIMEHeader = require( 'eml/Header' )
    local aHeader = {}
    local aBuffer = nil
    local aStart = 1
    local anEnd = nil
    
    while true do
        anEnd = aValue:find( '\n', aStart, true )
        if anEnd then
            local aLine = aValue:sub( aStart, anEnd - 1 )
            
            anEnd = anEnd + 1
            aStart = anEnd
            
            if aLine ~= '' then
                local aChar = aLine:sub( 1, 1 )
    
                if aChar ~= ' ' and aChar ~= '\t' then  
                    if aBuffer then
                        aHeader[ #aHeader + 1 ] = MIMEHeader( table.concat( aBuffer, ' ' ) )
                    end
            
                    aBuffer = {}
                end

                aBuffer[ #aBuffer + 1 ] = aLine
            else
                break
            end
        else
            break
        end
    end
    
    if aBuffer and #aBuffer > 0 then
        aHeader[ #aHeader + 1 ] = MIMEHeader( table.concat( aBuffer, ' ' ) )
    end
    
    return aHeader, ( anEnd or aStart )
end

local function NewHeaders( aValue )
    local someHeaders = nil
    local anEnd = nil
    
    if type( aValue ) == 'table' then
        someHeaders, anEnd = ReadHeaders( WriteHeaders( aValue ) )
    else
        someHeaders, anEnd = ReadHeaders( tostring( aValue or '' ) )
    end
    
    setmetatable( someHeaders, self )
    
    return someHeaders, anEnd
end

function meta:__call( aValue )
    return NewHeaders( aValue )
end

function self:__index( aKey )
   if aKey and type(aKey) == "string" then
        local someHeaders = {}
        aKey = aKey:lower()
        for anIndex, aHeader in ipairs( self ) do
            if aKey == aHeader.key then
                someHeaders[ #someHeaders + 1 ] = aHeader
            end
        end
        
        return table.unpack( someHeaders )
    end
    
    return nil
end

function self:__concat( aValue )
    return tostring( self ) .. tostring( aValue )
end

function self:__eq( aValue )
    return tostring( self ) == tostring( aValue )
end

function self:__tostring()
    return 'WriteHeaders'
end

return _M
