<?lsp

-- A simple example that lets you test the CAM API. The example opens
-- a cam object and saves the cam object in the persistent page
-- table. The result is sent as an image to the browser. Refreshing
-- the page returns a new captured image.  You can terminate the cam
-- object by accesing the url camread.lsp?close=.

-- See also wscam.lsp

if page.cam then
   if request:data"close" then
      page.cam:close()
      page.cam=nil
      response:senderror(200,"Cam closed!")
      return
   end
else -- Create
   -- Settings for Aideepen ESP32-CAM
   local cfg={
      d0=5, d1=18, d2=19, d3=21, d4=36, d5=39, d6=34, d7=35,
      xclk=0, pclk=22, vsync=25, href=23, sda=26, scl=27, pwdn=32,
      reset=-1, freq="20000000", frame="HD"
   }
   local err
   page.cam,err=esp32.cam(cfg)
   if not page.cam then
      response:senderror(503,err)
      return
   end
end
local image=page.cam:read()
response:reset()
response:setcontentlength(#image)
response:setcontenttype"image/jpeg"
response:send(image)
?>
