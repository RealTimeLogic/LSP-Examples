
local function decodeText(txt, cte)
   local function noaction(txt) return txt end
   local function decodeQP(txt)
      -- The parser canonicalizes message structure to LF, but quoted-printable
      -- soft wraps are defined on CRLF. Rebuild canonical line endings only
      -- for transfer decoding, then convert back to LF for the rest of the code.
      local decoded = mime.unqp((txt or ""):gsub("\n", "\r\n"))
      return decoded and decoded:gsub("\r\n", "\n")
   end
   local t={
      ["7bit"]=noaction,
      ["utf-8"]=noaction,
      ["quoted-printable"]=decodeQP,
      base64=ba.b64decode
   }
   local decoder=t[cte]
   if decoder then
      return decoder(txt)
   end
end


local function emsg(data)
   -- Parse message structure using LF internally.
   local m=require'eml/Decoder'(data:gsub("\r\n","\n"))
   local htmlbody,txtbody
   local htmlimg={}

   local charset
   local function doCharset(header)
      if charset then return end 
      local c=header["content-type"]
      charset = c and c.parameter.charset
      if not charset and htmlbody then
         charset=htmlbody:match"<%s*[Mm][Ee][Tt][Aa].-charset%s*=%s*(.-)%s*['\"]%s*>"
      end
   end

   local function extract(m)
      if type(m.content) == 'string' then
         local header={}
         for _,h in ipairs(m.header) do
            header[h.key]=h
         end
         local cte=header["content-transfer-encoding"]
         cte=cte and cte.value
         local cid=header["content-id"]
         if cid then
            cid=cid.value:gsub('<?([^>]-)>?','%1')
            if cte =="base64" then
               local content=ba.b64decode(m.content)
               if content then
                  table.insert(htmlimg,{id=cid,source=content,content=m.type})
               end
            end
         elseif m.type=="text/html" and not htmlbody then
            htmlbody=decodeText(m.content,cte)
         elseif m.type=="text/plain" and not txtbody then
            txtbody=decodeText(m.content,cte)
         end
         doCharset(header)
      elseif type(m.content) == 'table' then
         for _,mm in pairs(m.content) do
            extract(mm)
         end
      end
   end
   local ok,err=pcall(extract,m)
   if ok then
      if not htmlbody and not txtbody then return nil,"no body" end
      return {
         htmlbody=htmlbody,
         txtbody=txtbody,
         htmlimg=htmlimg,
         charset=charset
      }
   end
end

return emsg
