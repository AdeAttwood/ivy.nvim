local utils = require "ivy.utils"

it("will escape a dollar in the file name", function(t)
  local result = utils.escape_file_name "/path/to/$file/$name.lua"
  t.assert_equal(result, "/path/to/\\$file/\\$name.lua")
end)

it("will escape a brackets in the file name", function(t)
  local result = utils.escape_file_name "/path/to/[file]/[name].lua"
  t.assert_equal(result, "/path/to/\\[file\\]/\\[name\\].lua")
end)
