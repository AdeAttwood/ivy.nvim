local utils = {}

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
  return function(item)
    -- Match file and line form vimgrep style commands
    local file = item:match "([^:]+):"
    local line = item:match ":(%d+):"

    -- Cant do anything if we cant find a file to go to
    if file == nil then
      return
    end

    vim.cmd("edit " .. file)
    if line ~= nil then
      vim.cmd(line)
    end
  end
end

utils.file_action = function()
  return function(file)
    if file == nil then
      return
    end
    vim.cmd("edit " .. file)
  end
end

utils.line_action = function()
  return function(item)
    local line = item:match "^%s+(%d+):"
    vim.cmd(line)
  end
end

return utils
