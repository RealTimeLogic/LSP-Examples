------------------------------------------------------------------------------
--  LSP 2 HTML
------------------------------------------------------------------------------

local  format, gsub, strfind, strsub  = string.format, string.gsub, string.find, string.sub
local  assert, error = assert, error

local special_chars = {
  ['&'] = '&amp;',
  ['"'] = '&quot;',
  ['<'] = '&lt;',
  ['>'] = '&gt;',
}

local function special(x) return special_chars[x] end

local function quote(str)
  return(gsub(str, '([&"<>])', special))
end

local function colour(color)
  local quote = quote
  local b = '<font color="'.. color ..'">'
  local e = '</font>'
  return function(x) return b .. quote(x) .. e end
end

local function html(t, f)
  local b = '<'.. t ..'>'
  local e = '</'.. t ..'>'
  return function(x) return b .. f(x) .. e end
end

local operator = html('B',colour'#80000')
local decl     = colour'#0000FF'
local ctrl     = html('B',colour'#000000')
local std      = colour'#0000C2'
local literal  = colour'#008000'
local acomment = colour'#C08000'
local alsp     = html('B',colour'#FF7000')
local atext    = colour'#00CBDB'


local keywords_attr = {
  ['nil']       = literal,
  ['true']      = literal,
  ['false']     = literal,

 ['function']  = ctrl,

  ['local']     = decl,

  ['return']    = decl,
  ['break']     = decl,

  ['not']       = operator,
  ['and']       = operator,
  ['or']        = operator,


  ['if']        = ctrl,
  ['then']      = ctrl,
  ['else']      = ctrl,
  ['elseif']    = ctrl,

  ['for']       = ctrl,
  ['in']        = ctrl,
  ['while']     = ctrl,
  ['do']        = ctrl,
  ['end']       = ctrl,
  ['repeat']    = ctrl,
  ['until']     = ctrl,

  ['end']       = ctrl,
  ['<?lsp=']   = lsp,
  ['?>']   = lsp,

}

local other_attr = {
  ['%']   = decl,
  ['=']   = decl,
  ['{']   = html('B',decl),
  ['}']   = html('B',decl),
  ['#']   = operator,
  ['+']   = operator,
  ['-']   = operator,
  ['*']   = operator,
  ['/']   = operator,
  ['^']   = operator,
  ['<']   = operator,
  ['<=']  = operator,
  ['>']   = operator,
  ['>=']  = operator,
  ['==']  = operator,
  ['~=']  = operator,
}

local stdfunctions_attr = {
    arg = std,
    self = std,
    _G = std,
    _LOADED = std,
    _REQUIREDNAME = std,
    _TRACEBACK = std,
    _VERSION = std,
    assert = std,
    collectgarbage = std,
    coroutine = std,
      create = std,
      resume = std,
      status = std,
      wrap = std,
      yield = std,
    debug = std,
      debug = std,
      gethook = std,
      getinfo = std,
      getlocal = std,
      getupvalue = std,
      sethook = std,
      setlocal = std,
      setupvalue = std,
      traceback = std,
    dofile = std,
    error = std,
    gcinfo = std,
    getfenv = std,
    getmetatable = std,
    io = std,
      close = std,
      flush = std,
      input = std,
      lines = std,
      open = std,
      output = std,
      popen = std,
      read = std,
      stderr = std,
      stdin = std,
      stdout = std,
      tmpfile = std,
      type = std,
      write = std,
    ipairs = std,
    loadfile = std,
    loadlib = std,
    loadstring = std,
    math = std,
      abs = std,
      acos = std,
      asin = std,
      atan = std,
      atan2 = std,
      ceil = std,
      cos = std,
      deg = std,
      exp = std,
      floor = std,
      frexp = std,
      ldexp = std,
      log = std,
      log10 = std,
      max = std,
      min = std,
      mod = std,
      pi = std,
      pow = std,
      rad = std,
      random = std,
      randomseed = std,
      sin = std,
      sqrt = std,
      tan = std,
    newproxy = std,
    next = std,
    os = std,
      clock = std,
      date = std,
      difftime = std,
      execute = std,
      exit = std,
      getenv = std,
      remove = std,
      rename = std,
      setlocale = std,
      time = std,
      tmpname = std,
    pairs = std,
    pcall = std,
    print = std,
    rawequal = std,
    rawget = std,
    rawset = std,
    require = std,
    setfenv = std,
    setmetatable = std,
    string = std,
      byte = std,
      char = std,
      dump = std,
      find = std,
      format = std,
      gmatch = std,
      gsub = std,
      len = std,
      lower = std,
      rep = std,
      sub = std,
      upper = std,
    table = std,
      concat = std,
      foreach = std,
      foreachi = std,
      getn = std,
      insert = std,
      remove = std,
      setn = std,
      sort = std,
    tonumber = std,
    tostring = std,
    type = std,
    unpack = std,
    xpcall = std,
    __index = std,
    __newindex = std,
    __gc = std,
    __eq = std,
    __add = std,
    __sub = std,
    __mul = std,
    __div = std,
    __unm = std,
    __pow = std,
    __lt = std,
    __le = std,
    __concat = std,
    __call = std,
    __tostring = std,
    __metatable = std,
    __fenv = std,
}

local function sqstring(code, e)
  while 1 do
    e = strfind(code, '[\'\\]', e)
    if not e then error'bad single quoted string' end
    if strfind(code, '^\\.', e) then
      e = e+2
    elseif strfind(code, '^\'', e) then
      return e
    else
      error'impossible?'
    end
  end
end

local function dqstring(code, e)
  while 1 do
    e = strfind(code, '[\"\\]', e)
    if not e then error'bad double quoted string' end
    if strfind(code, '^\\.', e) then
      e = e+2
    elseif strfind(code, '^\"', e) then
      return e
    else
      error'impossible?'
    end
  end
end

local function longstring(code, e)
  local count = 0
  local b
  while 1 do
    b,e = strfind(code, '[%[%]].', e)
    if not b then error'bad long comment or string' end
    if strfind(code, '^%[%[', b) then
      e = e+1
      count = count+1
    elseif strfind(code, '^%]%]', b) then
      if count == 0 then
        return e
      end
      e = e+1
      count = count-1
    else
      -- okay
    end
  end
end

local function other(code, i)
  local b,e
  b,e = strfind(code, '^\'.', i)
  if b then return sqstring(code, e), literal end

  b,e = strfind(code, '^\".', i)
  if b then return dqstring(code, e), literal end

  b,e = strfind(code, '^%[%[.', i)
  if b then return longstring(code, e), literal end

  b,e = strfind(code, '^%.%.%.', i) if b then return e end
  b,e = strfind(code, '^%.%.', i)   if b then return e end
  b,e = strfind(code, '^%=%=', i)   if b then return e end
  b,e = strfind(code, '^%~%=', i)   if b then return e end
  b,e = strfind(code, '^%>%=', i)   if b then return e end
  b,e = strfind(code, '^%<%=', i)   if b then return e end

  return i
end

local function number(code, i)
  local b,e,e1,e2,e3
  b,e1 = strfind(code, '^%d+%.%d*', i)  -- D+ . D*
  b,e2 = strfind(code, '^%d*%.%d+', i)  -- D* . D+
  b,e3 = strfind(code, '^%d+', i)       -- D+
  i = e1 or e2 or e3
  b,e = strfind(code, '^[Ee][+-]?%d+', i+1)
  return e or i, literal
end

local function word(code, i)
  local b,e
  b,e = strfind(code, '^[_%a][_%w]*', i)
  local token = strsub(code, b, e)
  return e, keywords_attr[token] or stdfunctions_attr[token]
end

local function comment(code, i)
  local b,e
  b,e = strfind(code, '^%-%-%[%[.', i)
  if b then return longstring(code, e) end

  b,e = strfind(code, '^%-%-[^\n]*', i)
  if b then return e end
end

local function lsp(code, i)
  local b,e
  b,e = strfind(code, '^<%?lsp[=]?', i)
  if not b then
    b,e = strfind(code, '^%?%>', i)
  end
  return e, alsp
end



local function blsptag(code, i)
   return strfind(code, '^<%?lsp', i) or strfind(code, '^%?>', i)
end

local function blsptage(code, i)
   return strfind(code, '^%?>', i)
end
local function blsptags(code, i)
   return strfind(code, '^<%?lsp', i)
end


local function highlight(code, outfnc,filename)
  code = gsub(code, '\r\n', '\n')  -- DOS is a pain

  local line = { number = 0 }
  local function ln()
    line.number = line.number+1
    return format('\n<span style="color:silver;background:white">%4d  </span> ',
          line.number)
  end
  local function output(x, fmt)
    fmt = fmt or function(x) return x end
    x = gsub(x, '(%S[^\n]*)', fmt)  -- format groups of non-newline characters
    x = gsub(x, '\n', ln)           -- add line number after a newline
    outfnc(x)
  end
  output'\n'  -- line number 1
  local ws = 1
  local tok, e, fmt, inhtml
  inhtml=filename:find"%.lsp$" and true or false

  while 1 do
    e = ws

    if inhtml then
      outfnc'<div style="color:#706070;display:inline;">'
      local sp
      tok, sp = strfind(code, '<%?lsp', e)
      if tok then
        output(strsub(code, e, sp - 5), quote)
        outfnc'</div>'
        inhtml=false
        ws = sp - 4
        e = ws
      else
        output(strsub(code, e), quote)
        outfnc'</div>\n'
        break
      end
    end

    while 1 do  -- skips whitespace and comment
      tok = strfind(code, '%S', e)
      if not tok then return end
      if not strfind(code, '^[-]', tok) then break end
      e = comment(code, tok)
      if not e then break end
      e = e+1
    end
    output(strsub(code, ws, tok-1), acomment) -- white space and comments

    if blsptags(code, tok)              then e,fmt = lsp   (code, tok)
      inhtml=false
    elseif blsptage(code, tok)          then
      e,fmt = lsp   (code, tok)
      inhtml=true
    elseif strfind(code, '^[_%a]', tok) then e,fmt = word  (code, tok)
    elseif strfind(code, '^%.?%d', tok) then e,fmt = number(code, tok)
    elseif strfind(code, '^%p', tok)    then e,fmt = other (code, tok)
    else
      error'impossible?'
    end
    local token = strsub(code, tok, e)
    output(token, fmt or other_attr[token])

    ws = e+1
  end
end

return
  function (filename, io, outfnc)

    local fh,err = io:open(filename, "r")
    outfnc("<pre>\n")
    if not fh then return nil,err end
    local code =  fh:read"*a"
    fh:close()

    assert(outfnc, "an output function is required")
    outfnc("<h3>".. filename .."</h3>\n<hr /><pre>\n")
    highlight(code, outfnc, filename)
    outfnc'</pre><hr />\n'
    return true
  end
