local utils = require "ivy.utils"

local rg = {
  name = "RG",
  command = "IvyRg",
  description = "Run ripgrep to search for content in files",
  keymap = "<leader>/",
  items = utils.command_finder "rg --vimgrep --",
  callback = utils.vimgrep_action(),
}

return rg
