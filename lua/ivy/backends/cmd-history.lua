local libivy = require "ivy.libivy"

local cmd_history = {
  name = "CmdHistory",
  command = "IvyCmdHistory",
  description = "Search though your command history",
  keymap = "<c-r>",
}

cmd_history.items = function(input)
  local list = {}
  local history_list = vim.split(vim.fn.execute "history cmd", "\n")

  for index = 1, #history_list do
    local offset, line = string.match(history_list[index], "^%s+(%d+)%s+(.+)")

    if line then
      local score = libivy.ivy_match(input, line)
      if score > 50 then
        table.insert(list, { score = score + tonumber(offset), content = line })
      end
    end
  end

  table.sort(list, function(a, b)
    return a.score < b.score
  end)

  return list
end

cmd_history.callback = function(item)
  vim.cmd(item)
end

return cmd_history
