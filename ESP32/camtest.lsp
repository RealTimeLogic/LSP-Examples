<?lsp

-- A simple example that lets you test the CAM API. The result is sent
-- as an image to the browser. Refreshing the page returns a new
-- captured image.
-- See also wscam.lsp

-- Settings for 'FREENOVE ESP32-S3 WROOM' CAM board
-- Details: https://realtimelogic.com/ba/ESP32/source/cam.html
local cfg={
   d0=11, d1=9, d2=8, d3=10, d4=12, d5=18, d6=17, d7=16,
   xclk=15, pclk=13, vsync=6, href=7, sda=4, scl=5, pwdn=-1,
   reset=-1, freq="20000000", frame="HD"
}

local cam,err=esp32.cam(cfg)
if not cam then
   response:senderror(503,err)
   return
end
local image=cam:read()
response:reset()
response:setcontentlength(#image)
response:setcontenttype"image/jpeg"
response:send(image)
cam:close()

?>
