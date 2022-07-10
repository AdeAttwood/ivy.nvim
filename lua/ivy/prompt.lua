-- The prefix that will be before the search text for the user
local prompt_prefix = ">> "

local prompt = {}

prompt.value = ""

prompt.text = function()
  return prompt.value
end
prompt.update = function()
  vim.notify(prompt_prefix .. prompt.text())
end

prompt.input = function(char)
  if char == "BACKSPACE" then
    prompt.value = string.sub(prompt.value, 0, -2)
  elseif char == "\\\\" then
    prompt.value = prompt.value .. "\\"
  else
    prompt.value = prompt.value .. char
  end

  prompt.update()
end

prompt.set = function(value)
  prompt.value = value
  prompt.update()
end

prompt.destroy = function()
  prompt.value = ""
  vim.notify ""
end

return prompt
