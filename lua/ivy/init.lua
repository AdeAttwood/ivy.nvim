local controller = require "ivy.controller"
local register_backend = require "ivy.register_backend"

-- Local variable to check if ivy has been setup, this is to prevent multiple
-- setups of ivy
local has_setup = false

local ivy = {}
ivy.run = controller.run
ivy.register_backend = register_backend

---@class IvySetupOptions
---@field backends (IvyBackend | { ["1"]: string, ["2"]: IvyBackendOptions} | string)[]

---@param config IvySetupOptions
function ivy.setup(config)
  if has_setup then
    return
  end

  for _, backend in ipairs(config.backends) do
    register_backend(backend)
  end

  has_setup = true
end

return ivy
