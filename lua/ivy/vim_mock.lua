local mock = {
  commands = {},
}

mock.reset = function()
  mock.commands = {}

  _G.vim = {
    notify = function() end,
    cmd = function(cmd)
      table.insert(mock.commands, cmd)
    end,
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
end

return mock
