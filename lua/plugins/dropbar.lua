return {
  "Bekaboo/dropbar.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("dropbar").setup()

    local dropbar_api = require("dropbar.api")
    vim.keymap.set("n", "<leader>;", dropbar_api.pick, { desc = "Pick symbol in winbar" })
    vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of context" })
    vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
  end,
}
