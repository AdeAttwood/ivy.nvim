-- Constent options that will be used for the keymaps
local opts = { noremap = true, silent = true, nowait = true }

-- All of the base chars that will be used for an "input" operation on the
-- prompt
-- stylua: ignore
local chars = {
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W",
    "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t",
    "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "<", ">", "`", "@", "#", "~", "!",
    "\"", "$", "%", "^", "&", "/", "(", ")", "=", "+", "*", "-", "_", ".", ",", ";", ":", "?", "\\", "|", "'", "{", "}",
    "[", "]", " ",
}

local function string_to_table(lines)
  local matches = {}
  for line in lines:gmatch "[^\r\n]+" do
    table.insert(matches, { content = line })
  end

  return matches
end

local window = {}

window.index = 0
window.origin = nil
window.window = nil
window.buffer = nil

window.initialize = function()
  window.make_buffer()
end

window.make_buffer = function()
  window.origin = vim.api.nvim_get_current_win()

  vim.api.nvim_command "botright split new"
  window.buffer = vim.api.nvim_win_get_buf(0)
  window.window = vim.api.nvim_get_current_win()

  vim.api.nvim_win_set_option(window.window, "number", false)
  vim.api.nvim_win_set_option(window.window, "relativenumber", false)
  vim.api.nvim_win_set_option(window.window, "signcolumn", "no")

  vim.api.nvim_buf_set_option(window.buffer, "filetype", "ivy")
  vim.api.nvim_buf_set_var(window.buffer, "bufftype", "nofile")

  for index = 1, #chars do
    local char = chars[index]
    if char == "'" then
      char = "\\'"
    end
    if char == "\\" then
      char = "\\\\\\\\"
    end
    vim.api.nvim_buf_set_keymap(window.buffer, "n", chars[index], "<cmd>lua vim.ivy.input('" .. char .. "')<CR>", opts)
  end

  vim.api.nvim_buf_set_keymap(window.buffer, "n", "<C-c>", "<cmd>lua vim.ivy.destroy()<CR>", opts)
  vim.api.nvim_buf_set_keymap(window.buffer, "n", "<C-u>", "<cmd>lua vim.ivy.search('')<CR>", opts)
  vim.api.nvim_buf_set_keymap(window.buffer, "n", "<C-n>", "<cmd>lua vim.ivy.next()<CR>", opts)
  vim.api.nvim_buf_set_keymap(window.buffer, "n", "<C-p>", "<cmd>lua vim.ivy.previous()<CR>", opts)
  vim.api.nvim_buf_set_keymap(window.buffer, "n", "<C-M-n>", "<cmd>lua vim.ivy.next(); vim.ivy.checkpoint()<CR>", opts)
  vim.api.nvim_buf_set_keymap(
    window.buffer,
    "n",
    "<C-M-p>",
    "<cmd>lua vim.ivy.previous(); vim.ivy.checkpoint()<CR>",
    opts
  )
  vim.api.nvim_buf_set_keymap(window.buffer, "n", "<CR>", "<cmd>lua vim.ivy.complete()<CR>", opts)
  vim.api.nvim_buf_set_keymap(window.buffer, "n", "<BS>", "<cmd>lua vim.ivy.input('BACKSPACE')<CR>", opts)
  vim.api.nvim_buf_set_keymap(window.buffer, "n", "<Left>", "<cmd>lua vim.ivy.input('LEFT')<CR>", opts)
  vim.api.nvim_buf_set_keymap(window.buffer, "n", "<Right>", "<cmd>lua vim.ivy.input('RIGHT')<CR>", opts)
  vim.api.nvim_buf_set_keymap(window.buffer, "n", "<C-w>", "<cmd>lua vim.ivy.input('DELETE_WORD')<CR>", opts)
end

window.get_current_selection = function()
  local line = vim.api.nvim_buf_get_lines(window.buffer, window.index, window.index + 1, true)
  if line == nil then
    line = { "" }
  end

  return line[1]
end

window.get_buffer = function()
  if window.buffer == nil then
    window.make_buffer()
  end

  return window.buffer
end

window.update = function()
  vim.api.nvim_win_set_cursor(window.window, { window.index + 1, 0 })
end

window.set_items = function(items)
  if type(items) == "string" then
    items = string_to_table(items)
  end

  -- TODO(ade): Validate the items are in the correct format. This also need to
  -- come with some descriptive messages and possible help.

  -- Display no items text if there are no items to dispaly
  if #items == 0 then
    items = { { content = "-- No Items --" } }
  end

  local items_length = #items
  window.index = items_length - 1

  for index = 1, items_length do
    vim.api.nvim_buf_set_lines(window.buffer, index - 1, -1, false, { items[index].content })
  end

  -- Limit the results window size to 10 so when there are lots of results the
  -- window does not take up the hole terminal
  local line_count = items_length
  if line_count > 10 then
    line_count = 10
  end

  vim.api.nvim_win_set_height(window.window, line_count)
  window.update()
end

window.destroy = function()
  if type(window.buffer) == "number" then
    vim.api.nvim_buf_delete(window.buffer, { force = true })
  end

  window.buffer = nil
  window.window = nil
  window.origin = nil
  window.index = 0
end

return window
