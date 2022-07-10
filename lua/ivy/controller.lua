local window = require "ivy.window"
local prompt = require "ivy.prompt"

local controller = {}

controller.items = nil
controller.callback = nil

controller.run = function(items, callback)
  controller.callback = callback
  controller.items = items

  window.initialize()
  controller.input ""
end

controller.input = function(char)
  prompt.input(char)
  window.set_items(controller.items(prompt.text()))
end

controller.search = function(value)
  prompt.set(value)
  window.set_items(controller.items(prompt.text()))
end

controller.complete = function()
  controller.checkpoint()
  controller.destroy()
end

controller.checkpoint = function()
  vim.api.nvim_set_current_win(window.previous)
  controller.callback(window.get_current_selection())
  vim.api.nvim_set_current_win(window.window)
end

controller.next = function()
  window.index = window.index + 1
  window.update()
end

controller.previous = function()
  window.index = window.index - 1
  window.update()
end

controller.destroy = function()
  controller.items = nil
  controller.callback = nil

  window.destroy()
  prompt.destroy()
end

return controller
