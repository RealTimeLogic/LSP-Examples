local _M={}

local self = setmetatable( _M, {} )
local meta = getmetatable( self )

local function Capitalize( aValue )
    return ( aValue:lower():gsub( '(%l)([%w_\']*)', function( first, rest ) return first:upper() .. rest end ) )
end

local function ReadType( aHeader )
    local aHeader = aHeader or {}
    local aTypeHeader = aHeader[ 'content-type' ] or {}
    local aType = ( aTypeHeader.value or 'text/plain' ):lower()
    
    return aType
end

local function ContentModule( aType )
    local aName = 'eml/' .. Capitalize( aType ):gsub( '[^%w]', '' )
    local ok, aModule = pcall( require, aName )
    if not ok then
        local anIndex = aType:find( '/', 1, true )
        
        if anIndex then
            aModule = ContentModule( aType:sub( 1, anIndex - 1 ) )
        else
            aModule = nil
        end
    end
    
    return aModule
end

local function ReadContent( aValue, aType, aHeader )
    local aModule = ContentModule( aType )
    
    if aModule then
        return aModule( aValue, aHeader )
    end
    
    return aValue
end

local function ReadMIME( aValue )
    local MIMEHeaders = require( 'eml/Headers' )
    local aHeader, anEnd = MIMEHeaders( aValue )
    local aType = ReadType( aHeader )
    local aContent = ReadContent( aValue:sub( anEnd ), aType, aHeader )
    local aMIME = { header = aHeader, type = aType, content = aContent }
    
    return aMIME
end

local function NewMIME( aValue )
    local aMIME = nil
    
    if type( aValue ) == 'table' then
        aMIME = ReadMIME( WriteMIME( aValue ) )
    else
        aMIME = ReadMIME( tostring( aValue or '' ) )
    end
    
    setmetatable( aMIME, self )
    
    return aMIME
end

function meta:__call( aValue )
    return NewMIME( aValue )
end

function self:__concat( aValue )
    return tostring( self ) .. tostring( aValue )
end

function self:__eq( aValue )
    return tostring( self ) == tostring( aValue )
end

function self:__tostring()
    return 'WriteMIME' --WriteMIME( self )
end

return _M
