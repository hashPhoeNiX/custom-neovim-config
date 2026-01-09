-- Enhanced dbt configuration for Neovim
-- Combines dbtpal and dbt-power.nvim for Power User-like experience
--
-- dbt-power.nvim now supports multiple database adapters:
--   - Snowflake, PostgreSQL, BigQuery, Redshift, DuckDB, Databricks
--   - Auto-detects from dbt profiles (dbt Core) or uses dbt Cloud connections
--   - Falls back to dbt show if direct CLI not available

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
      -- Note: <leader>dm picker now handled by dbt-power (see below)
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
    -- "hashPhoeNiX/dbt-power.nvim",
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
            max_column_width = 12, -- Compact column width
            auto_clear_on_execute = false,
            style = "markdown",    -- or "simple"
          },

          -- Direct query configuration (direct CLI execution, bypasses dbt show truncation)
          direct_query = {
            max_rows = 100,         -- Default limit for direct query results
            buffer_split_size = 10, -- Height of results buffer in lines (configurable)
          },

          -- Compiled SQL preview
          preview = {
            auto_compile = false,
            split_position = "right", -- or "below"
            split_size = 80,
          },

          -- Database adapter configuration (auto-detects from ~/.dbt/profiles.yml)
          database = {
            -- Adapter selection: nil (auto-detect) or specify: "snowflake", "postgres", "bigquery", etc.
            adapter = nil, -- Auto-detect from profiles.yml (recommended)

            -- Adapter-specific configurations
            snowflake = {
              connection_name = "snowflake_dev", -- Connection name from ~/.snowsql/config
            },

            postgres = {
              host = "localhost",
              port = 5432,
              database = nil,
              user = nil,
              connection_string = nil, -- Alternative: full connection string
            },

            bigquery = {
              project_id = nil,
              dataset = nil,
              location = "US",
            },

            duckdb = {
              database_path = ":memory:",
            },

            redshift = {
              host = nil,
              port = 5439,
              database = nil,
              user = nil,
              connection_string = nil,
            },

            databricks = {
              host = nil,
              http_path = nil,
              token = nil,
            },

            -- Legacy vim-dadbod support (optional)
            use_dadbod = true,
            default_connection = nil,
          },

          -- Model picker configuration (replaces broken dbtpal picker)
          picker = {
            default = "fzf", -- "telescope" or "fzf"
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
            model_picker = "<leader>dm",
          },
        })
      end
    end,
  },
}
