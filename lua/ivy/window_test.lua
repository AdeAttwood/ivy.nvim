local vim_mock = require "ivy.vim_mock"
local window = require "ivy.window"

before_each(function()
  vim_mock.reset()
end)

it("can initialize", function(t)
  window.initialize()

  if window.get_buffer() ~= 10 then
    t.error("The windows buffer should be 10 found " .. window.get_buffer())
  end
end)
