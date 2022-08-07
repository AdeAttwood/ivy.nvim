package.path = "lua/?.lua;" .. package.path
local libivy = require "ivy.libivy"

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
      "| %-30s | %09.6f (s) | %09.6f (s) | %09.6f (s) | %09.6f (s) |",
      name,
      status.running_total,
      status.running_total / n,
      status.min,
      status.max
    )
  )
end

print "| Name                           | Total         | Adverage      | Min           | Max           |"
print "|--------------------------------|---------------|---------------|---------------|---------------|"

benchmark("ivy_match(file.lua) 1000000x", 1000000, function()
  libivy.ivy_match("file.lua", "some/long/path/to/file/file.lua")
end)

libivy.ivy_init "/tmp/ivy-trees/kubernetes"
benchmark("ivy_files(kubneties) 100x", 100, function()
  libivy.ivy_files("file.go", "/tmp/ivy-trees/kubernetes")
end)
