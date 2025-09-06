return {
  "hashPhoeNiX/youversion-linker.nvim",
  -- branch = "feat/initial-setup",
  -- dir = "~/Projects/youversion-linker.nvim",
  name = "youversion-linker",
  -- lazy = false,
  config = function()
    require("youversion-linker").setup({})
    -- Defer setup to avoid circular dependencies
    -- vim.schedule(function()
    --   require("youversion-linker").setup({})
    -- end)
  end
}
