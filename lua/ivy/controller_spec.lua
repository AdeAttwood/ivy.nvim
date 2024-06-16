local window = require "ivy.window"
local controller = require "ivy.controller"

describe("controller", function()
  before_each(function()
    vim.cmd "highlight IvyMatch cterm=bold gui=bold"
    window.initialize()
  end)

  after_each(function()
    controller.destroy()
  end)

  it("will run the completion", function()
    controller.run("Testing", function()
      return { { content = "Some content" } }
    end, function()
      return {}
    end)

    -- Run all the scheduled tasks
    vim.wait(0)

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
    assert.is_equal(#lines, 1)
    assert.is_equal(lines[1], "Some content")
  end)

  it("will not try and highlight the buffer if there is nothing to highlight", function()
    spy.on(vim, "cmd")

    controller.items = function()
      return { { content = "Hello" } }
    end

    controller.update ""

    vim.wait(0)

    assert.spy(vim.cmd).was_called_with "syntax clear IvyMatch"
    assert.spy(vim.cmd).was_not_called_with "syntax match IvyMatch '[H]'"
  end)

  it("will escape a - when passing it to be highlighted", function()
    spy.on(vim, "cmd")

    controller.items = function()
      return { { content = "Hello" } }
    end

    controller.update "some-file"

    vim.wait(0)

    assert.spy(vim.cmd).was_called_with "syntax match IvyMatch '[some\\-file]'"
  end)
end)
