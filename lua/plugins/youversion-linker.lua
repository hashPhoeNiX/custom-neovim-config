return {
  "hashPhoeNiX/youversion-linker.nvim",
  -- branch = "feat/initial-setup",
  -- dir = "~/Projects/youversion-linker.nvim",
  lazy = false,
  dev = true,
  config = function()
    require("youversion-linker").setup({})
    -- Defer setup to avoid circular dependencies
    -- vim.schedule(function()
    --   require("youversion-linker").setup({})
    -- end)
  end
}
