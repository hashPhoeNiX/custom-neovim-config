vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set nu")
vim.cmd("set relativenumber")
vim.cmd("set clipboard=unnamedplus")
vim.g.mapleader = " "
vim.opt.termguicolors = true

-- load the session for the current directory
vim.keymap.set("n", "<leader>qS", function() require("persistence").load() end)

-- select a session to load
vim.keymap.set("n", "<leader>qs", function() require("persistence").select() end)

-- load the last session
vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end)

-- stop Persistence => session won't be saved on exit
vim.keymap.set("n", "<leader>qd", function() require("persistence").stop() end)

-- create a keymap for Lazy 
vim.keymap.set('n', '<leader>l', function() require('lazy').home() end, { desc = 'Lazy' })

-- Directional window movements
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to lower window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to upper window' })
