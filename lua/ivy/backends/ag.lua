local utils = require "ivy.utils"

local ag = {
  name = "AG",
  command = "IvyAg",
  description = "Run ag to search for content in files",
  keymap = "<leader>/",
  items = utils.command_finder "ag",
  callback = utils.vimgrep_action(),
}

return ag
