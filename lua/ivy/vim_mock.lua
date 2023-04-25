local mock = {
  commands = {},
  lines = {},
  cursors = {},
}

mock.get_lines = function()
  return mock.lines
end

mock.get_commands = function()
  return mock.commands
end

mock.reset = function()
  mock.commands = {}
  mock.lines = {}
  mock.cursors = {}

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
      nvim_buf_set_name = function() end,
      nvim_buf_set_var = function() end,
      nvim_buf_set_keymap = function() end,
      nvim_buf_delete = function() end,
      nvim_buf_set_lines = function(buffer_number, state_index, end_index, _, items)
        local new_lines = {}

        for index = 1, state_index do
          if mock.lines[buffer_number][index] == nil then
            table.insert(new_lines, "")
          else
            table.insert(new_lines, mock.lines[buffer_number][index])
          end
        end

        for index = 1, #items do
          table.insert(new_lines, items[index])
        end

        if end_index ~= -1 then
          error("Mock of nvim_buf_set_lines dose not support a end_index grater than -1 found " .. end_index)
        end

        mock.lines[buffer_number] = new_lines
      end,
      nvim_win_set_height = function() end,
      nvim_win_set_cursor = function(window_number, position)
        mock.cursors[window_number] = position
      end,
      nvim_buf_get_lines = function(buffer_number, start_index, end_index)
        local lines = {}
        for index = start_index, end_index do
          table.insert(lines, mock.lines[buffer_number][index + 1])
        end

        if #lines == 0 then
          return nil
        end

        return lines
      end,
    },
    fn = {
      bufnr = function()
        return -1
      end,
    },
    schedule = function(callback)
      callback()
    end,
  }
end

return mock
