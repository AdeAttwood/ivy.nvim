local library_path = (function()
  local dirname = string.sub(debug.getinfo(1).source, 2, #"/fzf_lib.lua" * -1)
  return dirname .. "/../../target/release/libivyrs.so"
end)()

local ffi = require "ffi"
local ivy_c = ffi.load(library_path)

ffi.cdef [[
    typedef struct {  int score; const char* content; } match;
    typedef struct {  int len; match* matches; } match_list;

    void ivy_init(const char*);
    int ivy_match(const char*, const char*);
    match_list* ivy_files(const char*, const char*);
]]

local libivy = {}

libivy.ivy_init = function(dir)
  ivy_c.ivy_init(dir)
end

libivy.ivy_match = function(pattern, text)
  return ivy_c.ivy_match(pattern, text)
end

libivy.ivy_files = function(pattern, base_dir)
  return ivy_c.ivy_files(pattern, base_dir)
end

return libivy
