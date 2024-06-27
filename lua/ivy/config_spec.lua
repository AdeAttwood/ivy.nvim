local config = require "ivy.config"

describe("config", function()
  before_each(function()
    config.user_config = {}
  end)

  it("gets the first item when there is only default values", function()
    local first_backend = config:get { "backends", 1 }
    assert.is_equal("ivy.backends.buffers", first_backend)
  end)

  it("returns nil if we access a key that is not a valid config item", function()
    assert.is_nil(config:get { "not", "a", "thing" })
  end)

  it("returns the users overridden config value", function()
    config.user_config = { backends = { "ivy.my.backend" } }
    local first_backend = config:get { "backends", 1 }
    assert.is_equal("ivy.my.backend", first_backend)
  end)

  it("returns a nested value", function()
    config.user_config = { some = { nested = "value" } }
    assert.is_equal(config:get { "some", "nested" }, "value")
  end)
end)
