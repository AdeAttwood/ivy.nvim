local libivy = require "ivy.libivy"
local ffi = require "ffi"

it("should run a simple match", function(t)
  local score = libivy.ivy_match("term", "I am a serch term")

  if score <= 0 then
    t.error("Score should not be less than 0 found " .. score)
  end
end)
