local vim_mock = require "ivy.vim_mock"
local window = require "ivy.window"

before_each(function()
  vim_mock.reset()
end)

it("can initialize and destroy the window", function(t)
  window.initialize()

  t.assert_equal(10, window.get_buffer())
  t.assert_equal(10, window.buffer)

  window.destroy()
  t.assert_equal(nil, window.buffer)
end)

it("can set items", function(t)
  window.initialize()

  window.set_items { { content = "Line one" } }
  t.assert_equal("Line one", window.get_current_selection())
end)
