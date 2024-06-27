local ivy = require "ivy"
local config = require "ivy.config"

describe("ivy.setup", function()
  before_each(function()
    ivy.has_setup = false
    config.user_config = {}
  end)

  it("sets the users config options", function()
    ivy.setup { backends = { "ivy.backends.files" } }
    assert.is_equal("ivy.backends.files", config:get { "backends", 1 })
  end)

  it("will not reconfigure if its called twice", function()
    ivy.setup { backends = { "ivy.backends.files" } }
    ivy.setup { backends = { "some.backend" } }
    assert.is_equal("ivy.backends.files", config:get { "backends", 1 })
  end)

  it("does not crash if you don't pass in any params to the setup function", function()
    ivy.setup()
    assert.is_equal("ivy.backends.buffers", config:get { "backends", 1 })
  end)

  it("will fallback if the key is not set at all in the users config", function()
    ivy.setup { some_key = "some_value" }
    assert.is_equal("ivy.backends.buffers", config:get { "backends", 1 })
  end)
end)
