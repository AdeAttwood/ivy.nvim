-- The prefix that will be before the search text for the user
local prompt_prefix = ">> "

-- Gets the suffix to delete from some text biased on what happens in a bash
-- prompt. If the text dose not end in a letter then the last word and all of
-- the tailing special characters will be returned. If the text dose end in a
-- letter then only the last word will be returned leaving the special
-- characters that are before the last word. For example
--
-- `some word` -> `some `
-- `some     word` -> `some     `
-- `some word       ` -> `some `
local function get_delete_suffix(text)
  if text:match "([A-Za-z]+)$" == nil then
    return text:match "([A-Za-z]+[^A-Za-z]+)$"
  end

  return text:match "([A-Za-z]+)$"
end

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
    local suffix = get_delete_suffix(prompt.value)

    if suffix == nil then
      prompt.value = ""
    else
      prompt.value = prompt.value:sub(1, #prompt.value - #suffix)
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
