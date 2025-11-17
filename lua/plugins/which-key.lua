return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    preset = "helix",
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- dbt keymaps
    wk.add({
      { "<leader>d", group = "dbt" },
      -- dbtpal: run/test/compile
      { "<leader>dr", desc = "Run current model" },
      { "<leader>dR", desc = "Run all models" },
      { "<leader>dt", desc = "Test current model" },
      { "<leader>dT", desc = "Test all models" },
      { "<leader>dc", desc = "Compile current model" },
      { "<leader>dm", desc = "Find dbt model (Telescope)" },
      -- dbt-power: execute/preview
      { "<leader>dv", desc = "Preview compiled SQL" },
      { "<leader>ds", desc = "Execute inline" },
      { "<leader>dS", desc = "Execute buffer" },
      { "<leader>dC", desc = "Clear query results" },
      { "<leader>dA", desc = "Toggle auto-compile" },
      { "<leader>dq", desc = "Preview CTE" },
      { "<leader>da", desc = "Create ad-hoc model" },
      { "<leader>dx", desc = "Execute selection" },
      { "<leader>dP", desc = "Execute direct (buffer)" },
      { "<leader>dp", desc = "Execute direct (inline)" },
      -- dbt-power: build
      { "<leader>db", group = "build" },
      { "<leader>dbm", desc = "Build current model" },
      { "<leader>dbu", desc = "Build upstream" },
      { "<leader>dbd", desc = "Build downstream" },
      { "<leader>dba", desc = "Build all dependencies" },
    })
  end,
}
