local libivy = require "ivy.libivy"
local utils = require "ivy.utils"

local function items(term)
  return libivy.ivy_files(term, vim.fn.getcwd())
end

local files = {
  name = "Files",
  command = "IvyFd",
  description = "Find files in the project",
  keymap = "<leader>p",
  items = items,
  callback = utils.file_action(),
}

return files
