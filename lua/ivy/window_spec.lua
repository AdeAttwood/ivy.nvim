local window = require "ivy.window"
local controller = require "ivy.controller"
local config = require "ivy.config"
local ivy = require "ivy"

describe("window", function()
  before_each(function()
    _G.vim.ivy = ivy
    vim.cmd "highlight IvyMatch cterm=bold gui=bold"
  end)

  after_each(function()
    controller.destroy()

    config.user_config = {}
    ivy.has_setup = false
  end)

  it("can initialize and destroy the window", function()
    window.initialize()

    assert.is_equal(vim.api.nvim_get_current_buf(), window.buffer)

    window.destroy()
    assert.is_equal(nil, window.buffer)
  end)

  it("can set items", function()
    window.initialize()

    window.set_items { { content = "Line one" } }
    assert.is_equal("Line one", window.get_current_selection())
  end)

  it("will set the items when a string is passed in", function()
    window.initialize()

    local items = table.concat({ "One", "Two", "Three" }, "\n")
    window.set_items(items)

    assert.is_equal(items, table.concat(vim.api.nvim_buf_get_lines(window.buffer, 0, -1, true), "\n"))
  end)

  it("will error on invalid mapping callback", function()
    ivy.setup {
      mappings = {
        ["<CR>"] = "invalid_callback",
      },
    }

    assert.has_error(function()
      window.initialize()
    end, "The mapping 'invalid_callback' is not a valid ivy callback")
  end)

  it("will accept function callbacks", function()
    local was_called = false
    local test_fn = function()
      was_called = true
    end

    ivy.setup {
      mappings = {
        ["<C-1>"] = test_fn,
      },
    }

    vim.cmd "IvyLines"

    vim.wait(1)

    -- Trigger the mapping
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-1>", true, false, true), "x", true)

    assert.is_true(was_called)
  end)
end)
