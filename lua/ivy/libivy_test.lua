local libivy = require "ivy.libivy"

it("should run a simple match", function(t)
  local score = libivy.ivy_match("term", "I am a serch term")

  if score > 0 then
    t.error "Score should not be grater than 0"
  end
end)
