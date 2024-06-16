local utils = require "ivy.utils"
local vimgrep_action = utils.vimgrep_action()

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
    commands = { "buffer some/file.lua" },
  },
  {
    it = "will run the vsplit command",
    completion = "some/file.lua: This is some text",
    action = utils.actions.VSPLIT,
    commands = { "vsplit | buffer some/file.lua" },
  },
  {
    it = "will run the split command",
    completion = "some/file.lua: This is some text",
    action = utils.actions.SPLIT,
    commands = { "split | buffer some/file.lua" },
  },
}

describe("utils vimgrep_action", function()
  before_each(function()
    spy.on(vim, "cmd")
  end)

  after_each(function()
    vim.cmd:revert()
  end)

  for i = 1, #test_data do
    local data = test_data[i]
    it(data.it, function()
      assert.is_true(#data.commands > 0, "You must assert that at least one command is run")

      vimgrep_action(data.completion, data.action)
      assert.is_equal(#vim.cmd.calls, #data.commands, "The `vim.cmd` function should be called once")

      for j = 1, #data.commands do
        assert.spy(vim.cmd).was_called_with(data.commands[j])
      end
    end)
  end
end)
