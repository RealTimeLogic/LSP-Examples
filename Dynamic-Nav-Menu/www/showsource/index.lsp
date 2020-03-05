<?lsp
  -- first check to see if its a binary
  local url = request:data"url"
-- lets check for binary files. if binary just forward to the file
  local binary = {gif=true, png=true,jpg=true, jpeg=true, txt=true,cfg=true}
  if url then
    local suffix = url:match"%.([^%.]+)$"
    if binary[suffix] then
	  --remove the last path component
      url = (request:makeuri""):match"(.*)/[^/]*/$" .. url
	  url = url:gsub("//","/") -- just in case
      local st,err = response:forward(url)
      if not st then
	    error(err or url)
	  end
      return
    end
  end
?>

<HTML>
<head>
<!-- $Id: $  -->
<style type="text/css" MEDIA="screen, print">
<html>
<head>
<style>
body {
   background-color: white;
   font-family: "Trebuchet MS" Tahoma verdana, helvetica, arial, sans-serif;
   font-size: 10pt;
   font-weight: normal;
   margin-left: 10px;
   margin-right: 25px;
   color:black;
}

div.code, pre.code {
  white-space: pre;
  font: 12px, "Lucida Console","Courier New",monospace;
  color: black;
  margin-left: 1em;
  margin-top: .7em;
  margin-bottom: .7em;
  margin-right: auto;
  border: 4px;
  padding: 10px;
  border-style: ridge;
  background-color: #E5E5E5;
  background-color: #FFFFF0;
  page-break-inside:avoid;
  overflow: hidden;
}
</style>
<title>LSP source</title>
</head>
<body>
<?lsp
local data=request:data()
local fn = data.path

if not fn then print"Missing url param" return end
if not io:stat(fn) then
    response:senderror(404,string.format("%s not found", fn));
    return;
end
local f = assert(io:dofile(pathname:match("(.-)[^/]+$") .. "lsp2html.lua"))
f(fn, io, function(...) response:write(...) end)
f=nil
collectgarbage()

?>

</body>
</html>
