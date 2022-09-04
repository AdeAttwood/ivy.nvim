local window = require "ivy.window"

before_each(function()
  -- Mock the global vim functions we are using in the prompt
  _G.vim = {
    notify = function() end,
    api = {
      nvim_echo = function() end,
      nvim_get_current_win = function()
        return 10
      end,
      nvim_command = function() end,
      nvim_win_get_buf = function()
        return 10
      end,
      nvim_win_set_option = function() end,
      nvim_buf_set_option = function() end,
      nvim_buf_set_var = function() end,
      nvim_buf_set_keymap = function() end,
    },
  }
end)

it("can initialize", function(t)
  window.initialize()

  if window.get_buffer() ~= 10 then
    t.error("The windows buffer should be 10 found " .. window.get_buffer())
  end
end)
