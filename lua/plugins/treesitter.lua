-- nvim-treesitter is archived (April 2026) and superseded by Neovim 0.12's built-in treesitter.
-- Keeping the old config commented for reference.
--
-- return {
--   "nvim-treesitter/nvim-treesitter",
--   build = ":TSUpdate",
--   config = function()
--     require("nvim-treesitter.configs").setup({
--       ensure_installed = { "lua", "nix", "python" },
--       highlight = { enable = false },
--       indent = { enable = true },
--     })
--   end
-- }

-- Native Neovim 0.12 treesitter: enable highlighting for every filetype.
-- Parsers for common languages (lua, python, vim, vimdoc, etc.) ship with Neovim.
-- For additional parsers, ensure tree-sitter-cli is on PATH and run :TSInstall <lang>.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("native_treesitter", { clear = true }),
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

return {}
