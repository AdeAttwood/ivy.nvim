local libivy = require "ivy.libivy"
local utils = require "ivy.utils"

local function items(input)
  local list = {}
  local buffers = vim.api.nvim_list_bufs()
  for index = 1, #buffers do
    local buffer = buffers[index]
    -- Get the relative path from the current working directory. We need to
    -- substring +2 to remove the `/` from the start of the path to give us a
    -- true relative path
    local buffer_name = vim.api.nvim_buf_get_name(buffer):sub(#vim.fn.getcwd() + 2, -1)
    local file_type = vim.api.nvim_buf_get_option(buffer, "filetype")
    if vim.api.nvim_buf_is_loaded(buffer) and file_type ~= "ivy" and #buffer_name > 0 then
      local score = libivy.ivy_match(input, buffer_name)
      if score > -200 or #input == 0 then
        table.insert(list, { score = score, content = buffer_name })
      end
    end
  end

  table.sort(list, function(a, b)
    return a.score < b.score
  end)

  return list
end

local buffers = {
  name = "Buffers",
  command = "IvyBuffers",
  description = "List all of the current open buffers",
  keymap = "<leader>b",
  items = items,
  callback = utils.file_action(),
}

return buffers
