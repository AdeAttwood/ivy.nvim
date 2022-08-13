local libivy = require "ivy.libivy"

-- Helper function to test a that string `one` has  a higher match score than
-- string `two`. If string `one` has a lower score than string `two` a string
-- will be returned that can be used in body of an error. If not then `nil` is
-- returned and all is good.
local match_test = function(term, one, two)
  local score_one = libivy.ivy_match(term, one)
  local score_two = libivy.ivy_match(term, two)

  if score_one < score_two then
    return one .. " should be ranked higher than " .. two
  end

  return nil
end

it("sould match path separator", function(t)
  local result = match_test("file", "some/file.lua", "somefile.lua")
  if result then
    t.error(result)
  end
end)

it("sould match pattern with spaces", function(t)
  local result = match_test("so fi", "some/file.lua", "somefile.lua")
  if result then
    t.error(result)
  end
end)

it("sould match the start of a string", function(t)
  local result = match_test("file", "file.lua", "somefile.lua")
  if result then
    t.error(result)
  end
end)
