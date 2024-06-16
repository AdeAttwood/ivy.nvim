local utils = require "ivy.utils"

it("will escape a dollar in the file name", function()
  local result = utils.escape_file_name "/path/to/$file/$name.lua"
  assert.is_same(result, "/path/to/\\$file/\\$name.lua")
end)

it("will escape a brackets in the file name", function()
  local result = utils.escape_file_name "/path/to/[file]/[name].lua"
  assert.is_same(result, "/path/to/\\[file\\]/\\[name\\].lua")
end)
