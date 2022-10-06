local vim_mock = require "ivy.vim_mock"
local window = require "ivy.window"
local controller = require "ivy.controller"

-- The number of the mock buffer where all the test completions gets put
local buffer_number = 10

before_each(function()
  vim_mock.reset()
  window.initialize()
end)

after_each(function()
  controller.destroy()
end)

it("will run", function(t)
  controller.run("Testing", function()
    return { { content = "Some content" } }
  end, function()
    return {}
  end)

  local lines = vim_mock.get_lines()
  local completion_lines = lines[buffer_number]

  t.assert_equal(#completion_lines, 1)
  t.assert_equal(completion_lines[1], "Some content")
end)

it("will not try and highlight the buffer if there is nothing to highlight", function(t)
  controller.items = function()
    return { { content = "Hello" } }
  end

  controller.update ""
  local commands = vim_mock.get_commands()
  t.assert_equal(#commands, 1)
end)

it("will escape a - when passing it to be highlighted", function(t)
  controller.items = function()
    return { { content = "Hello" } }
  end

  controller.update "some-file"
  local commands = vim_mock.get_commands()
  local syntax_command = commands[2]

  t.assert_equal("syntax match IvyMatch '[some\\-file]'", syntax_command)
end)
