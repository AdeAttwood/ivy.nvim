local config = require "ivy.config"
local ivy = require "ivy"
local window = require "ivy.window"

describe("backends/lines", function()
  before_each(function()
    vim.cmd "highlight IvyMatch cterm=bold gui=bold"
    config.user_config = {}
    _G.vim.ivy = ivy

    ivy.setup()
  end)

  before_each(function()
    vim.cmd "edit /tmp/test.txt"
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      "Line one",
      "Line two",
      "Line three",
    })

    vim.cmd "IvyLines"
    vim.wait(0)
  end)

  after_each(function()
    ivy.destroy()
    vim.api.nvim_buf_delete(0, { force = true })
  end)

  it("will give the buffer the correct name", function()
    local buf_name = vim.api.nvim_buf_get_name(window.buffer)
    assert.is_true(vim.endswith(buf_name, "Lines"))
  end)

  it("will show all the lines in the file when nothing is selected", function()
    local lines = vim.api.nvim_buf_get_lines(window.buffer, 0, -1, false)
    assert.is_equal(#lines, 3)
  end)

  it("will sort the buffer when there is a selection", function()
    vim.ivy.search "three"
    vim.wait(0)

    local lines = vim.api.nvim_buf_get_lines(window.buffer, 0, -1, false)
    assert.is_equal(#lines, 3)

    local selection = window.get_current_selection()
    assert.is_equal(selection, "   3: Line three")
  end)
end)
