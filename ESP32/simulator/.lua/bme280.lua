
local B={} -- BME280 module

--Set the mode bits in the ctrl_meas register
-- Mode 00 = Sleep
-- 01 and 10 = Forced
-- 11 = Normal mode
function B:setMode(mode)
end

--Gets the current mode bits in the ctrl_meas register
--Mode 00 = Sleep
-- 01 and 10 = Forced
-- 11 = Normal mode
function B:getMode()
end

--Set the filter bits in the config register
--filter can be off or number of FIR coefficients to use:
--  0, filter off
--  1, coefficients = 2
--  2, coefficients = 4
--  3, coefficients = 8
--  4, coefficients = 16
function B:setFilter(filterSetting)
end

--Set the temperature oversample value
--0 turns off temp sensing
--1 to 16 are valid over sampling values
function B:setTempOverSample(overSampleAmount)
end

--Set the pressure oversample value
--0 turns off pressure sensing
--1 to 16 are valid over sampling values
function B:setPressureOverSample(overSampleAmount)
end

--Set the humidity oversample value
--0 turns off humidity sensing
--1 to 16 are valid over sampling values
function B:setHumidityOverSample(overSampleAmount)
end

--Set the standby bits in the config register
-- timeSetting can be:
--  0, 0.5ms
--  1, 62.5ms
--  2, 125ms
--  3, 250ms
--  4, 500ms
--  5, 1000ms
--  6, 10ms
--  7, 20ms
function B:setStandbyTime(timeSetting)
end

function B:close()
end

B.__index,B.__gc,B.__close=B,B.close,B.close


local temperature,humidity,pressure=20,50,1000*100

local rnd=math.random
function B:read()
   return (temperature+rnd(-10,10)/10),(humidity+rnd(-10,10)/10),(pressure+rnd(-100,100))
end



local function bme280(port, address, sda, scl, settings)
   return setmetatable({},B)
end

trace"Loading BME280 simulator"
return {create=bme280}
