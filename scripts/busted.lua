-- Script to run the busted cli tool. You can use this under nvim using be
-- below command. Any arguments can be passed in the same as the busted cli.
--
-- ```bash
-- nvim -l scripts/busted.lua
-- ```
vim.opt.rtp:append(vim.fn.getcwd())
require "busted.runner" { standalone = false }
