
local ELIZA -- A function set below. See http://en.wikipedia.org/wiki/ELIZA

-- Read a complete line from 'sock'
local function readline(sock)
   local len=0
   local tab={}
   while true do
      local data=sock:read()
      -- If socket closed.
      if not data then return nil end
      table.insert(tab, data)
      len = len + #data
      -- line if: NEWLINE or line > 140.
      if data:find("\n",1,true) or len > 140 then break end
   end
   return table.concat(tab) -- Assemble the line.
end

-- Called from eliza/wsserver.lsp: 
function elizaSockCoroutine(sock)
   trace"Starting ELIZA session"
   sock:write("Hello. I am ELIZA. How can I help you?\nYou: ",true)
   while true do
      local data=readline(sock)
      if not data then break end
      local rsp,bye=ELIZA(data)
      sock:write(string.format("Eliza: %s\n",rsp),true)
      if bye then break end
      sock:write("You: ", true)
   end
   trace"Closing ELIZA session"
end



------------------------------------------------------------------------
-- Joseph Weizenbaum's classic Eliza
-- This program is hereby placed into PUBLIC DOMAIN
------------------------------------------------------------------------
-- Original ELIZA paper:
--   ELIZA--A Computer Program For the Study of Natural Language
--   Communication Between Man and Machine,
--   Joseph Weizenbaum, 1966, Communications of the ACM Volume 9,
--   Number 1 (January 1966): 36-35.
--   URL: http://i5.nyu.edu/~mm64/x52.9265/january1966.html


ELIZA=function(text)
  local response = ""
  local user = string.upper(text)
  local userOrig = user

  -- randomly selected replies if no keywords
  local randReplies = {
    "WHAT DOES THAT SUGGEST TO YOU?",
    "I SEE...",
    "I'M NOT SURE I UNDERSTAND YOU FULLY.",
    "CAN YOU ELABORATE ON THAT?",
    "THAT IS QUITE INTERESTING!",
    "THAT'S SO... PLEASE CONTINUE...",
    "I UNDERSTAND...",
    "WELL, WELL... DO GO ON",
    "WHY ARE YOU SAYING THAT?",
    "PLEASE EXPLAIN THE BACKGROUND TO THAT REMARK...",
    "COULD YOU SAY THAT AGAIN, IN A DIFFERENT WAY?",
  }

  -- keywords, replies
  local replies = {
    [" CAN YOU"] = "PERHAPS YOU WOULD LIKE TO BE ABLE TO",
    [" DO YOU"] = "YES, I",
    [" CAN I"] = "PERHAPS YOU DON'T WANT TO BE ABLE TO",
    [" YOU ARE"] = "WHAT MAKES YOU THINK I AM",
    [" YOU'RE"] = "WHAT IS YOUR REACTION TO ME BEING",
    [" I DON'T"] = "WHY DON'T YOU",
    [" I FEEL"] = "TELL ME MORE ABOUT FEELING",
    [" WHY DON'T YOU"] = "WHY WOULD YOU WANT ME TO",
    [" WHY CAN'T I"] = "WHAT MAKES YOU THINK YOU SHOULD BE ABLE TO",
    [" ARE YOU"] = "WHY ARE YOU INTERESTED IN WHETHER OR NOT I AM",
    [" I CAN'T"] = "HOW DO YOU KNOW YOU CAN'T",
    [" SEX"] = "I FEEL YOU SHOULD DISCUSS THIS WITH A HUMAN.",
    [" I AM"] = "HOW LONG HAVE YOU BEEN",
    [" I'M"] = "WHY ARE YOU TELLING ME YOU'RE",
    [" I WANT"] = "WHY DO YOU WANT",
    [" WHAT"] = "WHAT DO YOU THINK?",
    [" HOW"] = "WHAT ANSWER WOULD PLEASE YOU THE MOST?",
    [" WHO"] = "HOW OFTEN DO YOU THINK OF SUCH QUESTIONS?",
    [" WHERE"] = "WHY DID YOU THINK OF THAT?",
    [" WHEN"] = "WHAT WOULD YOUR BEST FRIEND SAY TO THAT QUESTION?",
    [" WHY"] = "WHAT IS IT THAT YOU REALLY WANT TO KNOW?",
    [" PERHAPS"] = "YOU'RE NOT VERY FIRM ON THAT!",
    [" DRINK"] = "MODERATION IN ALL THINGS SHOULD BE THE RULE.",
    [" SORRY"] = "WHY ARE YOU APOLOGIZING?",
    [" DREAMS"] = "WHY DID YOU BRING UP THE SUBJECT OF DREAMS?",
    [" I LIKE"] = "IS IT GOOD THAT YOU LIKE",
    [" MAYBE"] = "AREN'T YOU BEING A BIT TENTATIVE?",
    [" NO"] = "WHY ARE YOU BEING NEGATIVE?",
    [" YOUR"] = "WHY ARE YOU CONCERNED ABOUT MY",
    [" ALWAYS"] = "CAN YOU THINK OF A SPECIFIC EXAMPLE?",
    [" THINK"] = "DO YOU DOUBT",
    [" YES"] = "YOU SEEM QUITE CERTAIN. WHY IS THIS SO?",
    [" FRIEND"] = "WHY DO YOU BRING UP THE SUBJECT OF FRIENDS?",
    [" COMPUTER"] = "WHY DO YOU MENTION COMPUTERS?",
    [" AM I"] = "YOU ARE",
  }

  -- conjugate
  local conjugate = {
    [" I "] = "YOU",
    [" ARE "] = "AM",
    [" WERE "] = "WAS",
    [" YOU "] = "ME",
    [" YOUR "] = "MY",
    [" I'VE "] = "YOU'VE",
    [" I'M "] = "YOU'RE",
    [" ME "] = "YOU",
    [" AM I "] = "YOU ARE",
    [" AM "] = "ARE",
  }

  -- random replies, no keyword
  local function replyRandomly()
     local r=ba.rnd() % #randReplies
     response = randReplies[r ~= 0 and r or 1].."\n"
  end

  -- find keyword, phrase
  local function processInput()
    for keyword, reply in pairs(replies) do
      local d, e = string.find(user, keyword, 1, 1)
      if d then
        -- process keywords
        response = response..reply.." "
        if string.byte(string.sub(reply, -1)) < 65 then -- "A"
          response = response.."\n"; return
        end
        local h = string.len(user) - (d + string.len(keyword))
        if h > 0 then
          user = string.sub(user, -h)
        end
        for cFrom, cTo in pairs(conjugate) do
          local f, g = string.find(user, cFrom, 1, 1)
          if f then
            local j = string.sub(user, 1, f - 1).." "..cTo
            local z = string.len(user) - (f - 1) - string.len(cTo)
            response = response..j.."\n"
            if z > 2 then
              local l = string.sub(user, -(z - 2))
              if not string.find(userOrig, l) then return end
            end
            if z > 2 then response = response..string.sub(user, -(z - 2)).."\n" end
            if z < 2 then response = response.."\n" end
            return
          end--if f
        end--for
        response = response..user.."\n"
        return
      end--if d
    end--for
    replyRandomly()
    return
  end

  -- main()
  -- accept user input
  if string.sub(user, 1, 3) == "BYE" then
    response = "BYE, BYE FOR NOW.\r\nSEE YOU AGAIN SOME TIME.\r\n"
    return response,true
  end
  if string.sub(user, 1, 7) == "BECAUSE" then
    user = string.sub(user, 8)
  end
  user = " "..user.." "
  -- process input, print reply
  processInput()
  return response
end

