-- The prefix that will be before the search text for the user
local prompt_prefix = ">> "

local prompt = {}

prompt.suffix = ""
prompt.value = ""

prompt.text = function()
  return prompt.value .. prompt.suffix
end
prompt.update = function()
  vim.api.nvim_echo({
    { prompt_prefix, "None" },
    { prompt.value:sub(1, -2), "None" },
    { prompt.value:sub(-1, -1), "Underlined" },
    { prompt.suffix, "None" },
  }, false, {})
end

prompt.input = function(char)
  if char == "BACKSPACE" then
    prompt.value = string.sub(prompt.value, 0, -2)
  elseif char == "LEFT" then
    if #prompt.value > 0 then
      prompt.suffix = prompt.value:sub(-1, -1) .. prompt.suffix
      prompt.value = prompt.value:sub(1, -2)
    end
  elseif char == "RIGHT" then
    if #prompt.suffix > 0 then
      prompt.value = prompt.value .. prompt.suffix:sub(1, 1)
      prompt.suffix = prompt.suffix:sub(2, -1)
    end
  elseif char == "DELETE_WORD" then
    prompt.value = prompt.value:match "(.*)%s+.*$"
    if prompt.value == nil then
      prompt.value = ""
    end
  elseif char == "\\\\" then
    prompt.value = prompt.value .. "\\"
  else
    prompt.value = prompt.value .. char
  end

  prompt.update()
end

prompt.set = function(value)
  prompt.value = value
  prompt.suffix = ""
  prompt.update()
end

prompt.destroy = function()
  prompt.value = ""
  prompt.suffix = ""
  vim.notify ""
end

return prompt
