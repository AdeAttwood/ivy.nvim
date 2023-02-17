local utils = {}

-- A list of all of the actions defined by ivy. The callback function can
-- implement as many of them as necessary. As a minimum it should implement the
-- "EDIT" action that is called on the default complete.
utils.actions = {
  EDIT = "EDIT",
  CHECKPOINT = "CHECKPOINT",
  VSPLIT = "VSPLIT",
  SPLIT = "SPLIT",
}

utils.command_map = {
  [utils.actions.EDIT] = "edit",
  [utils.actions.CHECKPOINT] = "edit",
  [utils.actions.VSPLIT] = "vsplit",
  [utils.actions.SPLIT] = "split",
}

utils.command_finder = function(command, min)
  if min == nil then
    min = 3
  end

  return function(input)
    -- Dont run the commands unless we have somting to search that wont
    -- return a ton of results or on some commands the command files with
    -- no search term
    if #input < min then
      return "-- Please type more than " .. min .. " chars --"
    end

    -- TODO(ade): Think if we want to start escaping the command here. I
    -- dont know if its causing issues while trying to use regex especially
    -- with word boundaries `input:gsub("'", "\\'"):gsub('"', '\\"')`
    local handle = io.popen(command .. " " .. input .. " 2>&1")
    if handle == nil then
      return {}
    end
    local result = handle:read "*a"
    handle:close()

    return result
  end
end

utils.vimgrep_action = function()
  return function(item, action)
    -- Match file and line form vimgrep style commands
    local file = item:match "([^:]+):"
    local line = item:match ":(%d+):"

    -- Cant do anything if we cant find a file to go to
    if file == nil then
      return
    end

    utils.file_action()(file, action)
    if line ~= nil then
      vim.cmd(line)
    end
  end
end

utils.file_action = function()
  return function(file, action)
    if file == nil then
      return
    end

    local command = utils.command_map[action]
    if command == nil then
      vim.api.nvim_err_writeln("[IVY] The file action is unable the handel the action " .. action)
      return
    end

    vim.cmd(command .. " " .. utils.escape_file_name(file))
  end
end

utils.line_action = function()
  return function(item)
    local line = item:match "^%s+(%d+):"
    vim.cmd(line)
  end
end

utils.escape_file_name = function(input)
  return string.gsub(input, "([$])", "\\%1")
end

return utils
