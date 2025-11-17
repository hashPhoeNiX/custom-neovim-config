-- Enhanced dbt configuration for Neovim
-- Combines dbtpal and dbt-power.nvim for Power User-like experience

return {
  -- dbtpal: Run and test dbt models
  {
    "PedramNavid/dbtpal",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    ft = { "sql", "md", "yaml" },
    config = function()
      require("dbtpal").setup({
        path_to_dbt = "dbt",          -- Use dbt Cloud CLI
        path_to_dbt_project = "",     -- Auto-detect
        include_profiles_dir = false, -- Don't pass --profiles-dir for dbt Cloud CLI
        path_to_dbt_profiles_dir = vim.fn.expand("~/.dbt"),
        -- Extended configuration
        extended_path_search = true,
        protect_compiled_files = true,
      })

      -- Load telescope extension
      require("telescope").load_extension("dbtpal")

      -- dbtpal keymaps (non-overlapping with dbt-power)
      local dbt_keymap = vim.api.nvim_set_keymap
      local opts = { noremap = true, silent = false }

      dbt_keymap("n", "<leader>dr", "<cmd>lua require('dbtpal').run_model()<cr>", opts)
      dbt_keymap("n", "<leader>dt", "<cmd>lua require('dbtpal').test_model()<cr>", opts)
      dbt_keymap("n", "<leader>dc", "<cmd>lua require('dbtpal').compile_model()<cr>", opts)
      dbt_keymap("n", "<leader>dm", "<cmd>lua require('dbtpal.telescope').dbt_picker()<cr>", opts)
      dbt_keymap("n", "<leader>dR", "<cmd>lua require('dbtpal').run_all_models()<cr>", opts)
      dbt_keymap("n", "<leader>dT", "<cmd>lua require('dbtpal').test_all_models()<cr>", opts)
    end,
  },

  -- Optional: MattiasMTS/cmp-dbt for dbt-specific autocompletion
  {
    "MattiasMTS/cmp-dbt",
    ft = { "sql", "yaml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("cmp-dbt").setup()
    end,
  },

  -- Custom dbt power functions (local development plugin)
  {
    dir = "~/Projects/dbt-power.nvim",
    name = "dbt-power",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "PedramNavid/dbtpal",
    },
    dev = true,
    ft = { "sql", "yaml", "md" },
    config = function()
      local ok, dbt_power = pcall(require, "dbt-power")
      if ok then
        dbt_power.setup({
          -- dbt Cloud CLI configuration
          dbt_cloud_cli = "dbt",
          dbt_project_dir = nil, -- Auto-detect

          -- Inline results configuration
          inline_results = {
            enabled = true,
            max_rows = 500,
            max_column_width = 12,  -- Compact column width
            auto_clear_on_execute = false,
            style = "markdown", -- or "simple"
          },

          -- Direct query configuration (snowsql execution, bypasses dbt show truncation)
          direct_query = {
            max_rows = 100,  -- Default limit for direct query results
            buffer_split_size = 10,  -- Height of results buffer in lines (configurable)
          },

          -- Compiled SQL preview
          preview = {
            auto_compile = false,
            split_position = "right", -- or "below"
            split_size = 80,
          },

          -- AI features (optional)
          ai = {
            enabled = false,
            provider = "anthropic", -- or "openai"
            api_key = os.getenv("ANTHROPIC_API_KEY"),
          },

          -- Keymaps (set to false to disable defaults)
          keymaps = {
            compile_preview = "<leader>dv",
            execute_inline = "<C-CR>",
            clear_results = "<leader>dC",
            toggle_auto_compile = "<leader>dA",
          },
        })
      end
    end,
  },
}
