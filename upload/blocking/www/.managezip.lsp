<!DOCTYPE html>
<html>
<head>
<link type="text/css" href="style.css" rel="Stylesheet" />
</head>
<body>
<?lsp

assert(zipname, "Something is very wrong") -- See index.lsp

local uio=app.uio -- The upload IO from .preload (app)

-- Copy data "from" file pointer "to" file pointer
local function copy(size,from,to)
   while size > 0 do
      local ok
      local chunk = size > 512 and 512 or size
      size = size - chunk
      local data = from:read(chunk)
      if data then
         -- We run in a separate thread, but the Lua VM is non
         -- preemptive. We want the firmware to behave like a
         -- background task and we simulate this by manually yielding
         -- such that other threads can run.
         ba.sleep(1) -- Let other resources run
         ok=to:write(data)
      end
      if not ok then
         response:write("I/O error\n")
         break
      end
   end
end


local zio,err=ba.mkio(uio, zipname)

if not zio then
   response:write(zipname, " is not a zip file ", err or "")
   -- Improve error management
else
   response:write"<pre>"
   response:write("In .managezip.lsp. Triggered by: ", isJavaScriptDragDrop and
                  "Drag and drop upload" or "HTTP form upload","\n")
   response:write("Data will be unzipped in: ",uio:realpath"",".\n\n")
   for name,isdir,mtime,size in zio:files("/",true) do
      if isdir then
         response:write("Skipping directory ",name,".\n")
      else
         local from = zio:open(name);
         if from then
            local to = uio:open(name, "w");
            if to then
               response:write("Extracting ",name,".\n")
               copy(size,from,to)
               to:close()
            else
               response:write("Cannot open output file",name,".\n")
            end
            from:close()
         else
            response:write("Cannot open input file",name,".\n")
         end
      end
   end
   response:write"</pre>"
end

?>
</body>
</html>


