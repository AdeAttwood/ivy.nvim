require "busted.runner"()

local libivy = require "ivy.libivy"

describe("libivy", function()
  it("should run a simple match", function()
    local score = libivy.ivy_match("term", "I am a serch term")

    assert.is_true(score > 0)
  end)

  it("should find a dot file", function()
    local current_dir = libivy.ivy_cwd()
    local results = libivy.ivy_files(".github/workflows/ci.yml", current_dir)

    assert.is_equal(2, results.length, "Incorrect number of results found")
    assert.is_equal(".github/workflows/ci.yml", results[2].content, "Invalid matches")
  end)

  it("will allow you to access the length via the metatable", function()
    local current_dir = libivy.ivy_cwd()
    local results = libivy.ivy_files(".github/workflows/ci.yml", current_dir)

    local mt = getmetatable(results)

    assert.is_equal(results.length, mt.__len(results), "The `length` property does not match the __len metamethod")
  end)

  it("will create an iterator", function()
    local iter = libivy.ivy_files(".github/workflows/ci.yml", libivy.ivy_cwd())
    local mt = getmetatable(iter)

    assert.is_equal(type(mt["__index"]), "function")
    assert.is_equal(type(mt["__len"]), "function")
  end)
end)
