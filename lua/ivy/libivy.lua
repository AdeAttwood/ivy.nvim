local library_path = (function()
  local root = string.sub(debug.getinfo(1).source, 2, #"/libivy.lua" * -1)
  local release_path = root .. "../../target/release"
  return package.searchpath("libivyrs", release_path .. "/?.so;" .. release_path .. "/?.dylib;")
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

    int ivy_files_iter(const char*, const char*);
    int ivy_files_iter_len(int);
    char* ivy_files_iter_at(int, int);
    void ivy_files_iter_delete(int);
]]

local iter_mt = {
  __len = function(self)
    return self.length
  end,
  __index = function(self, index)
    -- Pass in our index -1. This will map lua's one based indexing to zero
    -- based indexing that we are using in the rust lib.
    local item = ffi.string(ivy_c.ivy_files_iter_at(self.id, index - 1))
    return { content = item }
  end,
  __newindex = function(_, _, _)
    error("attempt to update a read-only table", 2)
  end,
  __gc = function(self)
    ivy_c.ivy_files_iter_delete(self.id)
  end,
}

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
  local iter_id = ivy_c.ivy_files_iter(pattern, base_dir)
  local iter_len = ivy_c.ivy_files_iter_len(iter_id)
  local iter = { id = iter_id, length = iter_len }
  setmetatable(iter, iter_mt)

  return iter
end

return libivy
