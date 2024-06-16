---@class IvyBackend
---@field command string The command this backend will have
---@field items fun(input: string): { content: string }[] | string The callback function to get the items to select from
---@field callback fun(result: string, action: string) The callback function to run when a item is selected
---@field description string? The description of the backend, this will be used in the keymaps
---@field name string? The name of the backend, this will fallback to the command if its not set
---@field keymap string? The keymap to trigger this backend

---@class IvyBackendOptions
---@field command string The command this backend will have
---@field keymap string? The keymap to trigger this backend

---Register a new backend
---
---This will create all the commands and set all the keymaps for the backend
---@param backend IvyBackend
local register_backend_class = function(backend)
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

---@param backend IvyBackend | { ["1"]: string, ["2"]: IvyBackendOptions} | string The backend or backend module
---@param options IvyBackendOptions? The options for the backend, that will be merged with the backend
local register_backend = function(backend, options)
  if type(backend[1]) == "string" then
    options = backend[2]
    backend = require(backend[1])
  end

  if type(backend) == "string" then
    backend = require(backend)
  end

  if options then
    for key, value in pairs(options) do
      backend[key] = value
    end
  end

  register_backend_class(backend)
end

return register_backend
