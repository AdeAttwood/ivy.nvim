local library_path = (function()
  local dirname = string.sub(debug.getinfo(1).source, 2, #"/fzf_lib.lua" * -1)
  return dirname .. "/../../target/release/libivyrs.so"
end)()

local ffi = require "ffi"
local ok, ivy_c = pcall(ffi.load, library_path)
if not ok then
  vim.api.nvim_err_writeln(
    "libivyrs.so not found! Please ensure you have complied the shared library."
      .. " For more info refer to the documentation, https://github.com/AdeAttwood/ivy.nvim#compiling"
  )

  return
end

ffi.cdef [[
    void ivy_init(const char*);
    char* ivy_cwd();
    int ivy_match(const char*, const char*);
    char* ivy_files(const char*, const char*);
]]

local libivy = {}

libivy.ivy_init = function(dir)
  ivy_c.ivy_init(dir)
end

libivy.ivy_cwd = function()
  return ffi.string(ivy_c.ivy_cwd())
end

libivy.ivy_match = function(pattern, text)
  return ivy_c.ivy_match(pattern, text)
end

libivy.ivy_files = function(pattern, base_dir)
  return ffi.string(ivy_c.ivy_files(pattern, base_dir))
end

return libivy
