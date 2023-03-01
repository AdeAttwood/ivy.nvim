local controller = require "ivy.controller"

-- Put the controller in to the vim global so we can access it in mappings
-- better without requires. You can call controller commands like `vim.ivy.xxx`.
-- luacheck: ignore
vim.ivy = controller

local register_backend = function(backend)
  assert(backend.command, "The backend must have a command")
  assert(backend.items, "The backend must have a items function")
  assert(backend.callback, "The backend must have a callback function")

  local user_command_options = { bang = true }
  if backend.description ~= nil then
    user_command_options.desc = backend.description
  end

  local name = backend.name or backend.command
  vim.api.nvim_create_user_command(backend.command, function()
    vim.ivy.run(name, backend.items, backend.callback)
  end, user_command_options)

  if backend.keymap ~= nil then
    vim.api.nvim_set_keymap("n", backend.keymap, "<cmd>" .. backend.command .. "<CR>", { nowait = true, silent = true })
  end
end

register_backend(require "ivy.backends.ag")
register_backend(require "ivy.backends.buffers")
register_backend(require "ivy.backends.files")
register_backend(require "ivy.backends.lines")

vim.cmd "highlight IvyMatch cterm=bold gui=bold"
