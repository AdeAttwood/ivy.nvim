local utils = require "ivy.utils"
local line_action = utils.line_action()

describe("utils line_action", function()
  before_each(function()
    spy.on(vim, "cmd")
  end)

  it("will run the line command", function()
    line_action " 4: Some text"

    assert.is_equal(#vim.cmd.calls, 1, "The `vim.cmd` function should be called once")
    assert.spy(vim.cmd).was_called_with "4"
  end)

  it("will run with more numbers", function()
    line_action " 44: Some text"

    assert.is_equal(#vim.cmd.calls, 1, "The `vim.cmd` function should be called once")
    assert.spy(vim.cmd).was_called_with "44"
  end)

  it("dose not run any action if no line is found", function()
    line_action "Some text"

    assert.spy(vim.cmd).was_not_called()
  end)
end)
