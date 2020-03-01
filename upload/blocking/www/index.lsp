<?lsp

local method=request:method() -- HTTP method the client using

if method ~= "GET" then
   -- Assume upload request.

   -- This is what we can manage
   -- PUT: drag and drop upload
   -- POST: form method='post' enctype='multipart/form-data'
   request:allow{"PUT", "POST"}

   -- Create a unique name for the upload
   page.uploadcntr = page.uploadcntr and page.uploadcntr+1 or 1
   -- Store the name in the request scope so we can use it in .managezip.lsp 
   zipname=string.format("upload%d.zip",page.uploadcntr)

   -- Open a file pointer for the data we will receive.
   local fp,err=app.uio:open(zipname,"w")
   if not fp then
      -- Improve error management
      response:write("Cannot create ",zipname,": ",err)
      return
   end

   -- Save data chunks received from the client
   local function filedata(data) fp:write(data) end

   -- Receive data using blocking read.
   if method == "PUT" then
      -- Used by drag and drop upload
      for data in request:rawrdr() do filedata(data) end
   else
      -- Used by form upload
      request:multipart{
         beginfile=function() end, -- Required, but not used.
         filedata=filedata,
         error=function(e) err=e end
      }
   end
   
   fp:close() -- Upload complete

   if err then
      -- Improve error management
      response:write("Cannot create ",zipname,": ",err)
      return
   end

   response:forward".managezip.lsp" -- Delegate request to .managezip.lsp
end
-- Else: run LSP page and emit data below.


--[[
The HTML below is split into 3 sections. The first section is for
managing a standard HTTP file upload form. The two last sections are
used by JavaScript in browsers that support drag and drop upload. The
two last sections are set to be invisible by CSS in style.css and will
not show up in browsers that do not have JavaScript enabled or that do
not support drag and drop upload. See the JavaScript code in upload.js
for more information.

1: "uploadform" is for the standard HTTP file upload form.

2: "dropbox" shows a drop image in the browser, when enabled by JS. The
   image can be found in the wfs embedded zip file.

3: "upload" shows the upload progress bar, when enabled by JS.
--]]


?>
<!DOCTYPE html>
<html>
  <head>
    <link type="text/css" href="style.css" rel="Stylesheet" />
    <script type="text/javascript" src="http://realtimelogic.com/rtl/jquery.js"></script>
    <script type="text/javascript" src="upload.js"></script>
  </head>
  <body>

    <p>Documentation: <a target="_blank" href="doc/README.html">README.html</a></p>

    <div id="uploadform">
      <div class="rtltmb">Upload Firmware</div>
      <div class="marg">
        <form method='post' enctype='multipart/form-data'>
          <p> File: <input  type='file' size='40' name='file'/></p>
          <input type='Submit' value='Upload' class="blackgrad"/>
        </form>
      </div>
    </div>


    <div id="dropbox">
      <div><img src="http://realtimelogic.com/rtl/wfm/dropbox.png"/></div>
      <p>Drag and drop to upload firmware.</p>
      <p><input id="showform" type="checkbox" /> Switch to upload form.</p>
    </div>


    <div id="upload">
      <table>
        <tr>
          <td>Uploading:&nbsp;<span id="uploading"></span></td>
        </tr>
        <tr>
          <td>
            <div class="progressbar">
              <div id="progressbar" class="progressbar-completed" style="width:0;">
                <div>&nbsp;</div>
              </div>
            </div>
          </td>
        </tr>
      </table>
    </div>
  </body>
</html>
