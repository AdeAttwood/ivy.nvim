package.path = "lua/?.lua;" .. package.path
local libivy = require "ivy.libivy"
local vim_mock = require "ivy.vim_mock"
local window = require "ivy.window"

local benchmark = function(name, n, callback)
  local status = {
    running_total = 0,
    min = 999999999999999999,
    max = -0000000000000000,
  }

  for _ = 1, n do
    local start_time = os.clock()
    callback()
    local running_time = os.clock() - start_time

    status.running_total = status.running_total + running_time
    if status.min > running_time then
      status.min = running_time
    end

    if status.max < running_time then
      status.max = running_time
    end
  end

  print(
    string.format(
      "| %-41s | %09.6f (s) | %09.6f (s) | %09.6f (s) | %09.6f (s) |",
      name,
      status.running_total,
      status.running_total / n,
      status.min,
      status.max
    )
  )
end

print "| Name                                      | Total         | Average       | Min           | Max           |"
print "|-------------------------------------------|---------------|---------------|---------------|---------------|"

benchmark("ivy_match(file.lua) 1000000x", 1000000, function()
  libivy.ivy_match("file.lua", "some/long/path/to/file/file.lua")
end)

libivy.ivy_init "/tmp/ivy-trees/kubernetes"
benchmark("ivy_files(kubernetes) 100x", 100, function()
  libivy.ivy_files("file.go", "/tmp/ivy-trees/kubernetes")
end)

-- Mock the vim API so we can run `vim.` functions. Override the
-- `nvim_buf_set_lines` function, this is so very slow. It saves all of the
-- lines so we can assert on them in the tests. For benchmarking we don't need
-- any of this, we can't control the vim internals.
vim_mock.reset()
_G.vim.api.nvim_buf_set_lines = function() end

window.initialize()

benchmark("ivy_files_with_set_items(kubernetes) 100x", 100, function()
  local items = libivy.ivy_files(".go", "/tmp/ivy-trees/kubernetes")
  window.set_items(items)
end)
