local examples = {
  "01_minimal_server.lua",
  "02_add_folder.lua",
  "03_add_variables.lua",
  "04_write_variable.lua",
  "05_value_callback.lua",
  "09_structure_type.lua"
}

local ok = true
local source = debug.getinfo(1, "S").source
if source:sub(1, 1) == "@" then
  source = source:sub(2)
end
local base = source:match("^(.*[/\\])") or ""

for _, example in ipairs(examples) do
  trace("RUN " .. example)
  local success, err = pcall(dofile, base .. example)
  if not success then
    ok = false
    trace("FAIL " .. example .. ": " .. tostring(err))
    break
  end
  trace("PASS " .. example)
end

mako.exit(ok and 0 or 1)
