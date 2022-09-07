local utils = require "ivy.utils"
local line_action = utils.line_action()
local vim_mock = require "ivy.vim_mock"

before_each(function()
  vim_mock.reset()
end)

it("will run the line command", function(t)
  line_action " 4: Some text"

  if #vim_mock.commands ~= 1 then
    t.error "`line_action` command length should be 1"
  end

  if vim_mock.commands[1] ~= "4" then
    t.error "`line_action` command should be 4"
  end
end)

it("will run with more numbers", function(t)
  line_action " 44: Some text"

  if #vim_mock.commands ~= 1 then
    t.error "`line_action` command length should be 1"
  end

  if vim_mock.commands[1] ~= "44" then
    t.error "`line_action` command should be 44"
  end
end)

it("dose not run any action if no line is found", function(t)
  line_action "Some text"

  if #vim_mock.commands ~= 0 then
    t.error "`line_action` command length should be 1"
  end
end)
