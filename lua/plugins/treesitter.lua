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
--
-- nix-wrapper-modules collates all grammars into a single COLLATED_TS_GRAMMARS
-- derivation symlinked into start/. The nix-info plugin (always present) exposes
-- its exact store path via require("nix-info").plugins.start["COLLATED_TS_GRAMMARS"].
-- This is the most reliable source; nixCats ts_grammar_path and packpath scanning
-- are kept as fallbacks for nixCats environments and non-Nix setups.
do
  local ts_path = _G.nixCats and nixCats.pawsible.allPlugins.ts_grammar_path
  if not ts_path or ts_path == "" then
    local start_dirs = {}

    -- nix-wrapper-modules: prefer nix-info for the exact COLLATED_TS_GRAMMARS path.
    local ok, nix_info = pcall(require, "nix-info")
    if ok and type(nix_info) == "table" then
      local collated = nix_info.plugins
        and nix_info.plugins.start
        and nix_info.plugins.start["COLLATED_TS_GRAMMARS"]
      if collated and collated ~= "" then
        -- Direct path: just add it, no scan needed.
        if vim.fn.isdirectory(collated .. "/parser") == 1 then
          vim.opt.rtp:prepend(collated)
        end
      end
      -- Also add the full start dir so any other grammar-bearing plugins are found.
      if nix_info.start_dir and nix_info.start_dir ~= "" then
        table.insert(start_dirs, nix_info.start_dir)
      end
    end

    -- nixCats: use vimPackDir.
    local pack_dir = _G.nixCats and nixCats.vimPackDir
    if pack_dir and pack_dir ~= "" then
      table.insert(start_dirs, pack_dir .. "/pack/myNeovimPackages/start")
    end

    -- Fallback: scan packpath (works when packdir is on packpath but not rtp).
    for _, p in ipairs(vim.opt.packpath:get()) do
      table.insert(start_dirs, p .. "/pack/myNeovimPackages/start")
    end

    local seen = {}
    for _, start in ipairs(start_dirs) do
      if not seen[start] and vim.fn.isdirectory(start) == 1 then
        seen[start] = true
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
