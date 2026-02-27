--------------------------------------------------------------------------------
-- MIMEHeader
--------------------------------------------------------------------------------

local _M={}

local self = setmetatable( _M, {} )
local meta = getmetatable( self )

local function Trim( aString )
    if aString ~= nil then
        aString = aString:gsub( '^[%c%s]*', '' )
        aString = aString:gsub( '[%s%c]*$', '' )
    end
    
    return aString
end

local function ReadKey( aValue )
    local anIndex = aValue:find( ':', 1, true ) or ( aValue:len() + 1 )
    local aKey = aValue:sub( 1, anIndex - 1 ):lower()
    
    return Trim( aKey )
end

local function ReadValue( aValue )
    local aValue = aValue .. ';'
    local anIndex = aValue:find( ':', 1, true ) or 1
    local anotherIndex = aValue:find( ';%s*([^%s=]+)%s*=(.-);' ) or aValue:len()
    local aValue = aValue:sub( anIndex + 1, anotherIndex - 1 )
    
    return Trim( aValue )
end

local function ReadParameter( aValue )
    local aValue = aValue .. ';'
    local aParameter = {}
    
    for aKey, aValue in aValue:gmatch( '%s*([^%s=]+)%s*=(.-);' ) do
            if aValue:sub( 1, 1 ) == '"' then
                    aValue = aValue:sub( 2, aValue:len() - 1 )
            end
    
            aParameter[ Trim( aKey ):lower() ] = Trim( aValue )
    end
    
    return aParameter
end

local function ReadHeader( aValue )
    local aHeaderKey = ReadKey( aValue )
    local aHeaderValue = ReadValue( aValue )
    local aHeaderParameter = ReadParameter( aValue )
    local aHeader = { key = aHeaderKey, value = aHeaderValue, parameter = aHeaderParameter }

    return aHeader
end

local function NewHeader( aValue )
    local aHeader = nil
    
    if type( aValue ) == 'table' then
        aHeader = ReadHeader( WriteHeader( aValue ) )
    else
        aHeader = ReadHeader( tostring( aValue or '' ) )
    end
    
    setmetatable( aHeader, self )
    
    return aHeader
end

function meta:__call( aValue )
    return NewHeader( aValue )
end

function self:__concat( aValue )
    return tostring( self ) .. tostring( aValue )
end

function self:__eq( aValue )
    return tostring( self ) == tostring( aValue )
end

function self:__lt( aValue )
    return tostring( self ) < tostring( aValue )
end

function self:__tostring()
    return 'WriteHeader' --WriteHeader( self )
end

return _M
