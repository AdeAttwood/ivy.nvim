package.path = "lua/?.lua;" .. package.path

local global_context = {
  current_test_name = "",
  before = {},
  after = {},
  before_each = {},
  after_each = {},
  total = 0,
  pass = 0,
  fail = 0,
}

local call_hook = function(hook_name)
  for index = 1, #global_context[hook_name] do
    global_context[hook_name][index]()
  end
end

_G.before_each = function(callback)
  table.insert(global_context.before_each, callback)
end

_G.after_each = function(callback)
  table.insert(global_context.after_each, callback)
end

_G.before = function(callback)
  -- currently before functions just get called because we only have a context
  -- of a test file. If we ever need to have more contexts then this will be to
  -- be differed.
  callback()
end

_G.after = function(callback)
  table.insert(global_context.after, callback)
end

_G.it = function(name, callback)
  local context = {
    name = name,
    error = function(message)
      error(message, 2)
    end,
    assert_equal = function(expected, actual)
      if expected ~= actual then
        error("Failed to assert that '" .. expected .. "' matches '" .. actual .. "'", 2)
      end
    end,
  }

  call_hook "before_each"

  local time = os.clock() * 1000
  local status, err = pcall(callback, context)
  local elapsed = (os.clock() * 1000) - time

  call_hook "after_each"

  local prefix = "\x1B[42mPASS"
  global_context.total = global_context.total + 1

  if status then
    global_context.pass = global_context.pass + 1
  else
    global_context.fail = global_context.fail + 1
    prefix = "\x1B[41mFAIL"
  end

  print(string.format("%s\x1B[0m %s - %s (%.3f ms)", prefix, global_context.current_test_name, name, elapsed))
  if err then
    print("  " .. err)
  end
end

local start_time = os.clock()
for _, name in ipairs(arg) do
  -- Turn the file name in to a lau module name that we can require
  local module = name:gsub("^lua/", "")
  module, _ = module:gsub("/init.lua$", "")
  module, _ = module:gsub(".lua$", "")
  module = module:gsub("/", ".")

  global_context.current_test_name = module:gsub("_test", "")
  require(module)
  call_hook "after"

  global_context.before_each = {}
  global_context.after_each = {}
  global_context.before = {}
  global_context.after = {}
end

print(string.format(
  [[

Tests: %d passed, %d total
Time:  %.3f seconds]],
  global_context.pass,
  global_context.total,
  (os.clock()) - start_time
))

if global_context.fail > 0 then
  os.exit(1, true)
end
