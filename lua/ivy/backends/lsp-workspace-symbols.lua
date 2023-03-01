local window = require "ivy.window"
local utils = require "ivy.utils"

local previous_results = {}
local function set_items(items)
  window.set_items(items)
  previous_results = items
end

local function items(input)
  local buffer_number = window.origin_buffer
  local cwd = vim.fn.getcwd()
  local results = {}
  vim.lsp.buf_request(buffer_number, "workspace/symbol", { query = input }, function(err, server_result, _, _)
    if err ~= nil then
      set_items { content = "-- There was an error with workspace/symbol --" }
      return
    end
    local locations = vim.lsp.util.symbols_to_items(server_result or {}, buffer_number) or {}
    for index = 1, #locations do
      local item = locations[index]
      local relative_path = item.filename:sub(#cwd + 2, -1)
      table.insert(results, { content = relative_path .. ":" .. item.lnum .. ": " .. item.text })
    end

    set_items(results)
  end)

  return previous_results
end

local lsp_workspace_symbols = {
  name = "WorkspaceSymbols",
  command = "IvyWorkspaceSymbols",
  description = "Search for workspace symbols using the lsp workspace/symbol",
  items = items,
  callback = utils.vimgrep_action(),
}

return lsp_workspace_symbols
