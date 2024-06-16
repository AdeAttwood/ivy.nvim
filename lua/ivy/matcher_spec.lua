local libivy = require "ivy.libivy"

-- Helper function to test a that string `one` has  a higher match score than
-- string `two`. If string `one` has a lower score than string `two` a string
-- will be returned that can be used in body of an error. If not then `nil` is
-- returned and all is good.
local match_test = function(term, one, two)
  local score_one = libivy.ivy_match(term, one)
  local score_two = libivy.ivy_match(term, two)

  assert.is_true(
    score_one > score_two,
    ("The score of %s (%d) ranked higher than %s (%d)"):format(one, score_one, two, score_two)
  )
end

describe("ivy matcher", function()
  it("should match path separator", function()
    match_test("file", "some/file.lua", "somefile.lua")
  end)

  -- it("should match pattern with spaces", function()
  --   match_test("so fi", "some/file.lua", "somefile.lua")
  -- end)

  it("should match the start of a string", function()
    match_test("file", "file.lua", "somefile.lua")
  end)
end)
