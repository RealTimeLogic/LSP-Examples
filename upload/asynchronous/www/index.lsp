<?lsp

if request:method() ~= "GET" then
   -- Assume upload request. See code in .preload for more information.
   app.upload(request) -- Does not return.
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
    <script type="text/javascript" src="https://realtimelogic.com/rtl/jquery.js"></script>
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
      <div><img src="https://realtimelogic.com/rtl/wfm/dropbox.png"/></div>
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
