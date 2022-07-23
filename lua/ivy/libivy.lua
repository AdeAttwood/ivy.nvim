local library_path = (function()
  local dirname = string.sub(debug.getinfo(1).source, 2, #"/fzf_lib.lua" * -1)
  -- return dirname .. "/../../build/Debug/lib/libivy.so"
  return dirname .. "/../../build/Release/lib/libivy.so"
end)()

local ffi = require "ffi"
local ivy_c = ffi.load(library_path)

ffi.cdef [[
    void ivy_init(const char*);
    int ivy_match(const char*, const char*);
    char* ivy_files(const char*, const char*);
]]

local libivy = {}

libivy.ivy_init = function(dir)
  ivy_c.ivy_init(dir)
end

libivy.ivy_match = function(pattern, text)
  return ivy_c.ivy_match(pattern, text)
end

libivy.ivy_files = function(pattern, base_dir)
  return ffi.string(ivy_c.ivy_files(pattern, base_dir))
end

return libivy
