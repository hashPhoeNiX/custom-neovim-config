-- Enhanced dbt configuration for Neovim
-- Combines dbtpal, vim-dadbod, and custom functions for Power User-like experience

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

      -- Key mappings (non-overlapping)
      local dbt_keymap = vim.api.nvim_set_keymap
      local opts = { noremap = true, silent = false }

      dbt_keymap("n", "<leader>dr", "<cmd>lua require('dbtpal').run_model()<cr>", opts)
      dbt_keymap("n", "<leader>dt", "<cmd>lua require('dbtpal').test_model()<cr>", opts)
      dbt_keymap("n", "<leader>dc", "<cmd>lua require('dbtpal').compile_model()<cr>", opts)
      dbt_keymap("n", "<leader>dm", "<cmd>lua require('dbtpal.telescope').dbt_picker()<cr>", opts)
      dbt_keymap("n", "<leader>dR", "<cmd>lua require('dbtpal').run_all_models()<cr>", opts)
      dbt_keymap("n", "<leader>dT", "<cmd>lua require('dbtpal').test_all_models()<cr>", opts)

      -- Custom: Show compiled SQL in split
      vim.keymap.set("n", "<leader>dv", function()
        require("dbt-power.preview").show_compiled_sql()
      end, { desc = "Preview compiled SQL", silent = false })

      -- Custom: Execute and show results inline (Power User approach: compile -> wrap -> execute)
      vim.keymap.set("n", "<C-CR>", function()
        require("dbt-power.execute").execute_and_show_inline()
      end, { desc = "Execute query (Power User mode)", silent = false })

      -- Custom: Execute using dbt show (alternative method)
      vim.keymap.set("n", "<leader>ds", function()
        require("dbt-power.execute").execute_with_dbt_show_command()
      end, { desc = "Execute query (dbt show mode)", silent = false })

      -- Visual mode: Execute selection
      vim.keymap.set("v", "<C-CR>", function()
        require("dbt-power.execute").execute_selection()
      end, { desc = "Execute SQL selection", silent = false })

      -- Custom: Clear inline results
      vim.keymap.set("n", "<leader>dC", function()
        require("dbt-power.ui.inline_results").clear_all()
      end, { desc = "Clear query results", silent = false })
    end,
  },

  -- vim-dadbod: Database interface
  {
    "tpope/vim-dadbod",
    cmd = "DB",
  },

  -- vim-dadbod-ui: UI for database queries
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection" },
    init = function()
      -- Database UI config
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_ui_win_position = "right"
      vim.g.db_ui_winwidth = 40

      -- Auto-execute on save
      vim.g.db_ui_auto_execute_table_helpers = 1

      -- Key mappings
      vim.keymap.set("n", "<leader>db", "<cmd>DBUIToggle<cr>", { noremap = true, silent = true, desc = "Toggle DBUI" })
    end,
  },

  -- vim-dadbod-completion: Autocomplete for SQL
  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = { "tpope/vim-dadbod" },
    ft = { "sql", "mysql", "plsql" },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          -- Check if blink.cmp is available
          local ok, cmp = pcall(require, "cmp")
          if ok then
            cmp.setup.buffer({
              sources = {
                { name = "vim-dadbod-completion" },
                { name = "buffer" },
              },
            })
          end
        end,
      })
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
      "tpope/vim-dadbod",
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
            max_column_width = 50,
            auto_clear_on_execute = false,
            style = "markdown", -- or "simple"
          },

          -- Compiled SQL preview
          preview = {
            auto_compile = false,
            split_position = "right", -- or "below"
            split_size = 80,
          },

          -- Database connections (will use vim-dadbod connections)
          database = {
            use_dadbod = true,
            default_connection = nil, -- Use DBUI default
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
