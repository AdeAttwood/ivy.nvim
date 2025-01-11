local controller = require "ivy.controller"
local libivy = require "ivy.libivy"
local config = require "ivy.config"
local utils = require "ivy.utils"
local register_backend = require "ivy.register_backend"

local ivy = {}

ivy.action = utils.actions
ivy.utils = utils

ivy.match = libivy.ivy_match

ivy.run = controller.run
ivy.register_backend = register_backend

ivy.checkpoint = controller.checkpoint
ivy.paste = controller.paste
ivy.complete = controller.complete
ivy.destroy = controller.destroy
ivy.input = controller.input
ivy.next = controller.next
ivy.previous = controller.previous
ivy.search = controller.search
ivy.origin_buffer = controller.origin_buffer
ivy.origin_window = controller.origin_window

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
