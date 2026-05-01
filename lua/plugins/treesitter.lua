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
-- Additional parsers are provided by Nix via nvim-treesitter.grammarPlugins.

-- Ensure grammar parser .so files are on the rtp.
-- lazyCat.lua resets vim.opt.rtp to a fixed list, which drops the
-- pack/myNeovimPackages/start/* entries Neovim added from packpath at startup.
-- In nixCats, ts_grammar_path replenishes the grammar path. In nix-wrapper-modules
-- that field may be absent, so we fall back to scanning the packpath directly.
do
  local ts_path = _G.nixCats and nixCats.pawsible.allPlugins.ts_grammar_path
  if not ts_path or ts_path == "" then
    for _, packdir in ipairs(vim.opt.packpath:get()) do
      local start = packdir .. "/pack/myNeovimPackages/start"
      if vim.fn.isdirectory(start) == 1 then
        for _, dir in ipairs(vim.fn.glob(start .. "/*", false, true)) do
          if vim.fn.isdirectory(dir .. "/parser") == 1 then
            vim.opt.rtp:prepend(dir)
          end
        end
      end
    end
  end
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("native_treesitter", { clear = true }),
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

return {}
