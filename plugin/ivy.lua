local controller = require "ivy.controller"
local utils = require "ivy.utils"

-- Put the controller in to the vim global so we can access it in mappings
-- better without requires. You can call controller commands like `vim.ivy.xxx`.
vim.ivy = controller

vim.api.nvim_create_user_command("IvyAg", function()
  vim.ivy.run(utils.command_finder "ag", utils.vimgrep_action())
end, { bang = true, desc = "Run ag to search for content in files" })

vim.api.nvim_create_user_command("IvyFd", function()
  vim.ivy.run(utils.command_finder("fd --hidden --type f --exclude .git", 0), utils.file_action())
end, { bang = true, desc = "Find files in the project" })

vim.api.nvim_create_user_command("IvyBuffers", function()
  vim.ivy.run(function(input)
    local list = {}
    local buffers = vim.api.nvim_list_bufs()
    for index = 1, #buffers do
      local buffer = buffers[index]
      local buffer_name = vim.api.nvim_buf_get_name(buffer)
      if vim.api.nvim_buf_is_loaded(buffer) and #buffer_name > 0 then
        table.insert(list, buffer_name)
      end
    end

    return list
  end, utils.file_action())
end, { bang = true, desc = "List all of the current open buffers" })

vim.api.nvim_set_keymap("n", "<leader>p", "<cmd>IvyFd<CR>", { nowait = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>/", "<cmd>IvyAg<CR>", { nowait = true, silent = true })
