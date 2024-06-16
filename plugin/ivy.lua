local controller = require "ivy.controller"
local register_backend = require "ivy.register_backend"

-- Put the controller in to the vim global so we can access it in mappings
-- better without requires. You can call controller commands like `vim.ivy.xxx`.
-- luacheck: ignore
vim.ivy = controller

vim.paste = (function(overridden)
  return function(lines, phase)
    local file_type = vim.api.nvim_buf_get_option(0, "filetype")
    if file_type == "ivy" then
      vim.ivy.paste()
    else
      overridden(lines, phase)
    end
  end
end)(vim.paste)

register_backend "ivy.backends.buffers"
register_backend "ivy.backends.files"
register_backend "ivy.backends.lines"
register_backend "ivy.backends.lsp-workspace-symbols"

if vim.fn.executable "rg" then
  register_backend "ivy.backends.rg"
elseif vim.fn.executable "ag" then
  register_backend "ivy.backends.ag"
end

vim.cmd "highlight IvyMatch cterm=bold gui=bold"
