local window = require "ivy.window"
local controller = require "ivy.controller"

describe("window", function()
  before_each(function()
    vim.cmd "highlight IvyMatch cterm=bold gui=bold"
    window.initialize()
  end)

  after_each(function()
    controller.destroy()
  end)

  it("can initialize and destroy the window", function()
    assert.is_equal(vim.api.nvim_get_current_buf(), window.buffer)

    window.destroy()
    assert.is_equal(nil, window.buffer)
  end)

  it("can set items", function()
    window.set_items { { content = "Line one" } }
    assert.is_equal("Line one", window.get_current_selection())
  end)

  it("will set the items when a string is passed in", function()
    local items = table.concat({ "One", "Two", "Three" }, "\n")
    window.set_items(items)

    assert.is_equal(items, table.concat(vim.api.nvim_buf_get_lines(window.buffer, 0, -1, true), "\n"))
  end)
end)
