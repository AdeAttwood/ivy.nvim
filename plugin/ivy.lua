local controller = require "ivy.controller"
local utils = require "ivy.utils"
local libivy = require "ivy.libivy"

-- Put the controller in to the vim global so we can access it in mappings
-- better without requires. You can call controller commands like `vim.ivy.xxx`.
-- luacheck: ignore
vim.ivy = controller

vim.api.nvim_create_user_command("IvyAg", function()
  vim.ivy.run("AG", utils.command_finder "ag", utils.vimgrep_action())
end, { bang = true, desc = "Run ag to search for content in files" })

vim.api.nvim_create_user_command("IvyFd", function()
  vim.ivy.run("Files", function(term)
    return libivy.ivy_files(term, vim.fn.getcwd())
  end, utils.file_action())
end, { bang = true, desc = "Find files in the project" })

vim.api.nvim_create_user_command("IvyBuffers", function()
  vim.ivy.run("Buffers", function(input)
    local list = {}
    local buffers = vim.api.nvim_list_bufs()
    for index = 1, #buffers do
      local buffer = buffers[index]
      -- Get the relative path from the current working directory. We need to
      -- substring +2 to remove the `/` from the start of the path to give us a
      -- true relative path
      local buffer_name = vim.api.nvim_buf_get_name(buffer):sub(#vim.fn.getcwd() + 2, -1)
      if vim.api.nvim_buf_is_loaded(buffer) and #buffer_name > 0 then
        local score = libivy.ivy_match(input, buffer_name)
        if score > -200 or #input == 0 then
          table.insert(list, { score = score, content = buffer_name })
        end
      end
    end

    table.sort(list, function(a, b)
      return a.score < b.score
    end)

    return list
  end, utils.file_action())
end, { bang = true, desc = "List all of the current open buffers" })

vim.api.nvim_create_user_command("IvyLines", function()
  vim.ivy.run("Lines", function(input)
    local list = {}

    local lines = vim.api.nvim_buf_get_lines(vim.ivy.origin(), 0, -1, false)
    for index = 1, #lines do
      local line = lines[index]
      local score = libivy.ivy_match(input, line)
      if score > -200 then
        local prefix = string.rep(" ", 4 - #tostring(index)) .. index .. ": "
        table.insert(list, { score, prefix .. line })
      end
    end

    table.sort(list, function(a, b)
      return a[1] < b[1]
    end)

    return list
  end, utils.line_action())
end, { bang = true, desc = "List all of the current open buffers" })

vim.api.nvim_set_keymap("n", "<leader>b", "<cmd>IvyBuffers<CR>", { nowait = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>p", "<cmd>IvyFd<CR>", { nowait = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>/", "<cmd>IvyAg<CR>", { nowait = true, silent = true })

vim.cmd "highlight IvyMatch cterm=bold"
