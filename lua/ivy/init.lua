local controller = require "ivy.controller"
local config = require "ivy.config"
local register_backend = require "ivy.register_backend"

local ivy = {}
ivy.run = controller.run
ivy.register_backend = register_backend

-- Private variable to check if ivy has been setup, this is to prevent multiple
-- setups of ivy. This is only exposed for testing purposes.
---@private
ivy.has_setup = false

---@class IvySetupOptions
---@field backends (IvyBackend | { ["1"]: string, ["2"]: IvyBackendOptions} | string)[]

---@param user_config IvySetupOptions
function ivy.setup(user_config)
  if ivy.has_setup then
    return
  end

  config.user_config = user_config or {}

  for _, backend in ipairs(config:get { "backends" } or {}) do
    register_backend(backend)
  end

  ivy.has_setup = true
end

return ivy
