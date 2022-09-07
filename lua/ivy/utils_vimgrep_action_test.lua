local utils = require "ivy.utils"
local vimgrep_action = utils.vimgrep_action()
local vim_mock = require "ivy.vim_mock"

before_each(function()
  vim_mock.reset()
end)

local test_data = {
  {
    it = "will edit some file and goto the line",
    completion = "some/file.lua:2: This is some text",
    action = utils.actions.EDIT,
    commands = {
      "edit some/file.lua",
      "2",
    },
  },
  {
    it = "will skip the line if its not matched",
    completion = "some/file.lua: This is some text",
    action = utils.actions.EDIT,
    commands = { "edit some/file.lua" },
  },
  {
    it = "will run the vsplit command",
    completion = "some/file.lua: This is some text",
    action = utils.actions.VSPLIT,
    commands = { "vsplit some/file.lua" },
  },
  {
    it = "will run the split command",
    completion = "some/file.lua: This is some text",
    action = utils.actions.SPLIT,
    commands = { "split some/file.lua" },
  },
}

for i = 1, #test_data do
  local data = test_data[i]
  it(data.it, function(t)
    vimgrep_action(data.completion, data.action)

    if #vim_mock.commands ~= #data.commands then
      t.error("Incorrect number of commands run expected " .. #data.commands .. " but found " .. #vim_mock.commands)
    end

    for j = 1, #data.commands do
      if vim_mock.commands[j] ~= data.commands[j] then
        t.error(
          "Incorrect command run expected '" .. data.commands[j] .. "' but found '" .. vim_mock.commands[j] .. "'"
        )
      end
    end
  end)
end
