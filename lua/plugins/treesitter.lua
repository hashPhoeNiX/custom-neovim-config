return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "lua", "nix", "python" },
      highlight = { enable = false },
      indent = { enable = true },
    })
  end
}
