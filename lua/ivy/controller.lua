local window = require "ivy.window"
local prompt = require "ivy.prompt"

local controller = {}

controller.items = nil
controller.callback = nil

controller.run = function(name, items, callback)
  controller.callback = callback
  controller.items = items

  window.initialize()

  window.set_items { { content = "-- Loading ---" } }
  vim.api.nvim_buf_set_name(window.get_buffer(), name)

  controller.input ""
end

controller.input = function(char)
  prompt.input(char)
  controller.update(prompt.text())
end

controller.search = function(value)
  prompt.set(value)
  controller.update(prompt.text())
end

controller.update = function(text)
  vim.schedule(function()
    window.set_items(controller.items(text))
    vim.cmd "syntax clear IvyMatch"
    vim.cmd("syntax match IvyMatch '[(" .. text .. ")]'")
  end)
end

controller.complete = function()
  vim.api.nvim_set_current_win(window.origin)
  controller.callback(window.get_current_selection())

  controller.destroy()
end

controller.checkpoint = function()
  vim.api.nvim_set_current_win(window.origin)
  controller.callback(window.get_current_selection())
  vim.api.nvim_set_current_win(window.window)
end

controller.next = function()
  local max = vim.api.nvim_buf_line_count(window.buffer) - 1
  if window.index == max then
    return
  end

  window.index = window.index + 1
  window.update()
end

controller.previous = function()
  if window.index == 0 then
    return
  end

  window.index = window.index - 1
  window.update()
end

controller.origin = function()
  return vim.api.nvim_win_get_buf(window.origin)
end

controller.destroy = function()
  controller.items = nil
  controller.callback = nil

  window.destroy()
  prompt.destroy()
end

return controller
