local utils = require "ivy.utils"
local libivy = require "ivy.libivy"

local function items(input)
  local list = {}

  local lines = vim.api.nvim_buf_get_lines(vim.ivy.origin(), 0, -1, false)
  for index = 1, #lines do
    local line = lines[index]
    local score = libivy.ivy_match(input, line)
    if score > -200 then
      local prefix = string.rep(" ", 4 - #tostring(index)) .. index .. ": "
      table.insert(list, { score = score, content = prefix .. line })
    end
  end

  table.sort(list, function(a, b)
    return a.score < b.score
  end)

  return list
end

local lines = {
  name = "Lines",
  command = "IvyLines",
  description = "Search though the lines in the current buffer",
  items = items,
  callback = utils.line_action(),
}

return lines
