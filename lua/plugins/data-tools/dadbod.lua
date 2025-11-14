-- Database connections via vim-dadbod
-- Ad-hoc SQL execution without dbt
-- Loads Snowflake credentials from .env file in project root

local function load_env()
  local env = {}
  local env_file = vim.fn.expand("~/.config/nvim/.env")

  -- Try project-local .env first, then fallback to global
  if vim.fn.filereadable(vim.fn.getcwd() .. "/.env") == 1 then
    env_file = vim.fn.getcwd() .. "/.env"
  end

  if vim.fn.filereadable(env_file) == 0 then
    return env
  end

  for line in io.lines(env_file) do
    -- Skip comments and empty lines
    if line:match("^[^#]") and line:match("=") then
      local key, value = line:match("^([^=]+)=(.*)$")
      if key then
        -- Trim whitespace
        key = key:gsub("^%s+|%s+$", "")
        value = value:gsub("^%s+|%s+$", "")
        -- Remove quotes if present
        value = value:gsub('^["\'](.*)["\'"]$', "%1")
        env[key] = value
      end
    end
  end
  return env
end

return {
  -- vim-dadbod: Database interface
  {
    "tpope/vim-dadbod",
    cmd = "DB",
    keys = {
      { "<leader>db", "<cmd>DBUIToggle<cr>", desc = "Toggle Database UI" },
      { "<leader>dB", "<cmd>DB ",            desc = "Execute DB command" },
    },
  },

  -- vim-dadbod-ui: Interactive database UI
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function()
      -- Database UI configuration
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_ui_win_position = "right"
      vim.g.db_ui_winwidth = 50
      vim.g.db_ui_table_helpers = {
        snowflake = {
          List = "SELECT * FROM {table}",
          Columns = "DESC TABLE {table}",
          Count = "SELECT COUNT(*) FROM {table}",
        },
      }

      -- Auto-execute on save for query buffers
      vim.g.db_ui_auto_execute_table_helpers = 1

      -- Setup Snowflake connections from environment variables
      local function setup_snowflake_connections()
        local user = os.getenv("SNOWFLAKE_USER")
        local account = os.getenv("SNOWFLAKE_ACCOUNT")
        local warehouse = os.getenv("SNOWFLAKE_WAREHOUSE")
        local private_key_path = os.getenv("SNOWFLAKE_PRIVATE_KEY_PATH")
        local role = os.getenv("SNOWFLAKE_ROLE") or "ENGINEER_ROLE"

        if not (user and account and warehouse and private_key_path) then
          vim.notify(
            "[vim-dadbod] Missing Snowflake env vars: SNOWFLAKE_USER, SNOWFLAKE_ACCOUNT, SNOWFLAKE_WAREHOUSE, SNOWFLAKE_PRIVATE_KEY_PATH",
            vim.log.levels.WARN
          )
          return
        end

        -- Expand home directory in path
        local expanded_key_path = vim.fn.expand(private_key_path)

        -- Build Snowflake connection string
        -- Format: snowflake://user@account/database?warehouse=X&role=Y&private_key_path=Z
        local function build_connection(database)
          return string.format(
            "snowflake://%s@%s/%s?warehouse=%s&role=%s&private_key_path=%s",
            user,
            account,
            database,
            warehouse,
            role,
            expanded_key_path
          )
        end

        -- Get database names from env vars, with defaults
        local databases = {
          raw = os.getenv("SNOWFLAKE_RAW_DB") or "RAW_DB",
          analytics = os.getenv("SNOWFLAKE_ANALYTICS_DB") or "ANALYTICS_DB",
          staging = os.getenv("SNOWFLAKE_STAGING_DB") or "STAGING_DB",
          dev = os.getenv("SNOWFLAKE_DEV_DB") or "SANDBOX_DB",
        }

        -- Configure connections
        vim.g.dbs = {
          snowflake_raw = build_connection(databases.raw),
          snowflake_analytics = build_connection(databases.analytics),
          snowflake_staging = build_connection(databases.staging),
          snowflake_dev = build_connection(databases.dev),
        }

        -- Set default connection
        vim.g.db_ui_default_connection = "snowflake_raw"

        -- Notify success
        vim.notify(
          "[vim-dadbod] Snowflake connections loaded: " .. table.concat(
            vim.tbl_keys(vim.g.dbs),
            ", "
          ),
          vim.log.levels.INFO
        )
      end

      setup_snowflake_connections()
    end,
  },

  -- vim-dadbod-completion: SQL autocomplete from database
  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = { "tpope/vim-dadbod" },
    ft = { "sql" },
    init = function()
      -- Setup autocommand for SQL files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql" },
        group = vim.api.nvim_create_augroup("dadbod_completion", { clear = true }),
        callback = function(opts)
          local bufnr = opts.buf
          -- Enable dadbod completion in SQL buffers
          if vim.fn.exists("g:dbs") == 1 then
            -- Add dadbod source to cmp if available
            local ok, cmp = pcall(require, "cmp")
            if ok then
              cmp.setup.buffer({
                sources = cmp.config.sources(
                  {
                    { name = "vim-dadbod-completion" },
                  },
                  {
                    { name = "buffer" },
                  }
                ),
              })
            end
          end
        end,
      })
    end,
  },
}
