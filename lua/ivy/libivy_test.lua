local libivy = require "ivy.libivy"

it("should run a simple match", function(t)
  local score = libivy.ivy_match("term", "I am a serch term")

  if score <= 0 then
    t.error("Score should not be less than 0 found " .. score)
  end
end)

it("should find a dot file", function(t)
  local current_dir = libivy.ivy_cwd()
  local results = libivy.ivy_files(".github/workflows/ci.yml", current_dir)

  if results.length ~= 2 then
    t.error("Incorrect number of results found " .. results.length)
  end

  if results[2].content ~= ".github/workflows/ci.yml" then
    t.error("Invalid matches: " .. results[2].content)
  end
end)

it("will allow you to access the length via the metatable", function(t)
  local current_dir = libivy.ivy_cwd()
  local results = libivy.ivy_files(".github/workflows/ci.yml", current_dir)

  local mt = getmetatable(results)

  if results.length ~= mt.__len(results) then
    t.error "The `length` property does not match the __len metamethod"
  end
end)

it("will create an iterator", function(t)
  local iter = libivy.ivy_files(".github/workflows/ci.yml", libivy.ivy_cwd())
  local mt = getmetatable(iter)

  if type(mt["__index"]) ~= "function" then
    t.error "The iterator does not have an __index metamethod"
  end

  if type(mt["__len"]) ~= "function" then
    t.error "The iterator does not have an __len metamethod"
  end
end)
