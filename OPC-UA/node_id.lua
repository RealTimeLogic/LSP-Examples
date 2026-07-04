----------------------------------------------
--   Examples of node ID string notation -----

-- integer with namespace index 1.
local numberNode = 'ns=1;i=100'
-- By default, namespace is zero
local numberNode = 'i=100'

-- String
local stringNode = 'ns=1;s=string'
local stringNode = 's=string'

-- Guid
local guidNode = 'ns=100;g=00000001-0002-0003-0405-060708090a0b'
local guidNode = 'g=00000001-0002-0003-0405-060708090a0b'

--ByteString
local byteStringNodeId = 'b=iuZVz8N6YulzlqYeA+P7qAGDCX8Wj1uxon37fqROcqc='
--ByteString with non zero namespace index
local byteStringNodeId = 'ns=1;b=iuZVz8N6YulzlqYeA+P7qAGDCX8Wj1uxon37fqROcqc='

-------------------------------------------------------------
--   Functions for creating node IDs in string notation -----

local nodeId = require("opcua.node_id")

-- Numeric

-- 'i=100'
local nodeIdString = nodeId.toString(100)
local nodeIdString = nodeId.toString({id=100})

-- 'ns=1;i=100'
local nodeIdString = nodeId.toString(100, 1)
local nodeIdString = nodeId.toString({id=100, 1})

-- String

-- 's=hello'
local nodeIdString = nodeId.toString('hello')
local nodeIdString = nodeId.toString({id='hello'})

-- 'ns=1;s=hello'
local nodeIdString = nodeId.toString('hello', 1)
local nodeIdString = nodeId.toString({id='hello', ns=1})

-- GUID
local guid = "00000001-0002-0003-0405-060708090a0b"

-- 'g=00000001-0002-0003-0405-060708090a0b'
local nodeIdString = nodeId.toString(guid)
local nodeIdString = nodeId.toString({id=guid})

-- 'ns=1;g=00000001-0002-0003-0405-060708090a0b'
local nodeIdString = nodeId.toString(guid, 1)
local nodeIdString = nodeId.toString({id=guid, ns=1})

-- ByteString

-- 'b=AQIDBAUGBw=='
local nodeIdString = nodeId.toString({1,2,3,4,5,6,7})
local nodeIdString = nodeId.toString({id={1,2,3,4,5,6,7}})

-- 'ns=1;b=AQIDBAUGBw=='
local nodeIdString = nodeId.toString({1,2,3,4,5,6,7}, 1)
local nodeIdString = nodeId.toString({id={1,2,3,4,5,6,7}, ns=1})


-------------------------------------------------------
--- Functions for parsing string notation of node ID --

local nodeId = require("opcua.node_id")

-- Numeric

-- {id=100}
local nodeIdtbl = nodeId.fromString('i=100')

-- {id=100,ns=1}
local nodeIdtbl = nodeId.fromString('ns=1;i=100')

-- String

-- {id='hello'}
local nodeIdtbl = nodeId.toString('s=hello')

-- {id='hello', ns=1}
local nodeIdtbl = nodeId.toString('ns=1;s=hello')

-- GUID

--   guid = "00000001-0002-0003-0405-060708090a0b"
--
--  nodeIdtbl = {id = guid, type=ua.nodeId.Guid}
local nodeIdtbl = nodeId.fromString('g=00000001-0002-0003-0405-060708090a0b')

-- 'ns=1;g=00000001-0002-0003-0405-060708090a0b'
local nodeIdtbl = nodeId.fromString('ns=1;g=00000001-0002-0003-0405-060708090a0b')

-- ByteString
-- byteString = {1,2,3,4,5,6,7}

-- {id=byteString}
local nodeIdtbl = nodeId.toString('b=AQIDBAUGBw==')

-- {id={1,2,3,4,5,6,7}, ns=1, type=ua.nodeId.ByteString}
local nodeIdtbl = nodeId.fromString('ns=1;b=AQIDBAUGBw==')
