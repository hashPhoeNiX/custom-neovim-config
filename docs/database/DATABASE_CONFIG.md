# Database Configuration for dbt in Neovim

This guide explains how to set up database connections for inline query execution in your dbt Neovim workflow.

## Overview

Your dbt setup uses the `dbt show` command for previewing model results:

- **Command**: `dbt show --select <model_name> --max-rows 500`
- **What it does**: Compiles the model, executes the SQL, returns results preview
- **No materialization**: Results are not saved to warehouse
- **Available**: All dbt versions

## Step 1: Check Your dbt Version

```bash
dbt --version
```

The `dbt show` command is available in all dbt versions. If you have an older version:

**Option A: Install dbt Cloud CLI** (Recommended)
```bash
brew install dbt-labs/dbt/dbt
```

**Option B: Upgrade via pip**
```bash
pip install --upgrade dbt-core dbt-snowflake  # or dbt-postgres, dbt-bigquery
```

## Step 2: Configure dbt Profiles

Your dbt project must be properly configured with a profiles file.

### Check Current Profile

```bash
cd ~/Projects/custom-neovim/data-dpac-dbt-models
dbt debug
```

This will show you if your profile is properly configured.

### Configure dbt Cloud CLI

If using dbt Cloud CLI:

```bash
# Login to dbt Cloud
dbt cloud cli authenticate

# Or manually configure ~/.dbt/dbt_cloud.yml
mkdir -p ~/.dbt
cat > ~/.dbt/dbt_cloud.yml << 'EOF'
# Visit https://cloud.getdbt.com/api-tokens to get your token
api_token: "YOUR_API_TOKEN_HERE"
EOF
```

### Configure dbt Core with Snowflake (Your Case)

Create `~/.dbt/profiles.yml`:

```yaml
reliance_health:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: YOUR_SNOWFLAKE_ACCOUNT
      user: YOUR_USERNAME
      password: YOUR_PASSWORD
      role: YOUR_ROLE
      database: YOUR_DATABASE
      schema: dev
      warehouse: YOUR_WAREHOUSE
      threads: 4
      client_session_keep_alive: False

    prod:
      type: snowflake
      account: YOUR_SNOWFLAKE_ACCOUNT
      user: YOUR_USERNAME
      password: YOUR_PASSWORD
      role: YOUR_PROD_ROLE
      database: YOUR_PROD_DATABASE
      schema: prod
      warehouse: YOUR_PROD_WAREHOUSE
      threads: 4
      client_session_keep_alive: False
```

**Using Environment Variables** (More Secure):

```yaml
reliance_health:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: "{{ env_var('DBT_SNOWFLAKE_ACCOUNT') }}"
      user: "{{ env_var('DBT_SNOWFLAKE_USER') }}"
      password: "{{ env_var('DBT_SNOWFLAKE_PASSWORD') }}"
      role: "{{ env_var('DBT_SNOWFLAKE_ROLE') }}"
      database: "{{ env_var('DBT_SNOWFLAKE_DATABASE') }}"
      schema: dev
      warehouse: "{{ env_var('DBT_SNOWFLAKE_WAREHOUSE') }}"
      threads: 4
```

Then set in your shell (`~/.zshrc` or `~/.bashrc`):

```bash
export DBT_SNOWFLAKE_ACCOUNT="ab12345.us-east-1"
export DBT_SNOWFLAKE_USER="your_username"
export DBT_SNOWFLAKE_PASSWORD="your_password"
export DBT_SNOWFLAKE_ROLE="DEVELOPER"
export DBT_SNOWFLAKE_DATABASE="ANALYTICS"
export DBT_SNOWFLAKE_WAREHOUSE="COMPUTE_WH"
```

### Configure PostgreSQL (Alternative)

```yaml
my_dbt_project:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      user: your_username
      password: your_password
      port: 5432
      dbname: your_database
      schema: dev
      threads: 4
      keepalives_idle: 0
```

## Step 3: Test dbt Show Command

```bash
cd ~/Projects/custom-neovim/data-dpac-dbt-models

# Test connection
dbt debug

# Test show command (preview results without materializing)
dbt show --select stg_customers --max-rows 10
```

If this works, you're ready to use inline query execution!

## Step 4: Configure vim-dadbod (Fallback/Alternative)

If you prefer to use vim-dadbod instead, add database connections to your Neovim config:

### Method 1: Environment Variable

Add to `~/.zshrc`:

```bash
# For Snowflake
export DBUI_DEFAULT="snowflake://user:password@account/database"

# For PostgreSQL
export DBUI_DEFAULT="postgresql://user:password@localhost/database"
```

### Method 2: Neovim Config

Add to `lua/config/init.lua` or a separate file:

```lua
-- Database connections for vim-dadbod
vim.g.dbs = {
  dev = "postgresql://user:password@localhost:5432/dev_db",
  prod = "postgresql://user:password@prod-host:5432/prod_db",
  snowflake = "snowflake://user:password@account/db/schema",
}
```

### Method 3: Interactive Setup

In Neovim, use DBUI:

```vim
:DBUIToggle
" Press 'a' to add a new connection
" Enter connection string in format: postgresql://user:pass@host/db
```

## Step 5: Verify Setup in Neovim

1. Open a dbt model file:
```bash
cd ~/Projects/custom-neovim/data-dpac-dbt-models
nvim models/staging/stg_customers.sql
```

2. Test dbt commands:
```vim
" Compile current model
<leader>dc

" Run current model
<leader>dr

" Preview compiled SQL
<leader>dv
```

3. Test inline execution:
```vim
" Open a dbt model file
" Position cursor at the end
" Press Ctrl+Enter to execute using dbt show
<C-CR>

" You should see results displayed inline as a markdown table
```

## Troubleshooting

### Error: "dbt show command not found"

- Your dbt version is older or dbt is not installed properly
- Solution: Run `dbt --version` to check, or install/upgrade dbt

### Error: "Not in a dbt project"

- Your dbt_project.yml is not found
- Solution: Make sure you're in the project root directory

### Error: "Failed to compile model"

```vim
" Run this manually to see the actual error
dbt compile --select your_model_name
```

Check for:
- Missing dependencies (macros, packages)
- Invalid Jinja syntax
- Profile configuration issues

### Error: "No database connection configured"

- vim-dadbod fallback is activated but no connection is set up
- Solution: Configure using one of the methods above

```vim
" To debug in Neovim:
:echo vim.g.db
:echo vim.g.dbs
```

### Results not displaying

1. Check if execution succeeded:
```vim
:messages  " Look for error messages
```

2. Verify database connection:
```vim
" Test with DBUI
:DBUIToggle
" Select a table and press Enter to see data
```

3. Try with explicit LIMIT:
```sql
-- In your model or selection
SELECT * FROM {{ ref('my_table') }} LIMIT 10
```

## Advanced: Custom Database Credentials

### Using Environment Variables in dbt_project.yml

```yaml
vars:
  snowflake_account: "{{ env_var('DBT_SNOWFLAKE_ACCOUNT') }}"
  database: "{{ env_var('DBT_SNOWFLAKE_DATABASE') }}"
```

Then use in models:
```sql
SELECT * FROM {{ var('database') }}.schema.table
```

### Dynamic Connection Switching

In Neovim:
```lua
-- lua/config/db-switcher.lua
local M = {}

function M.switch_target(target_name)
  vim.fn.system("cd " .. vim.fn.getcwd() .. " && dbt parse --target " .. target_name)
  vim.notify("[dbt] Switched to target: " .. target_name)
end

vim.api.nvim_create_user_command("DbSwitch", function(opts)
  M.switch_target(opts.args)
end, { nargs = 1 })

return M
```

Usage:
```vim
:DbSwitch prod
<leader>dr  " Now runs against prod
```

## Performance Tips

1. **Use LIMIT in preview queries**
   - The inline execution already adds `LIMIT 500` by default
   - Configure in dbt.lua: `max_rows = 500`

2. **Use dbt show for quick previews**
   - `dbt show` handles all dbt syntax (ref, source, macros) automatically
   - Combines compilation and execution in one command

3. **Cache compiled SQL**
   - Run `dbt compile` once, then use inline execution
   - Avoid recompiling on every execution

## Additional Resources

- [dbt Profiles Docs](https://docs.getdbt.com/dbt-cli/configure-your-profile)
- [vim-dadbod Documentation](https://github.com/tpope/vim-dadbod)
- [Your dbt Project Config](./data-dpac-dbt-models/dbt_project.yml)

## Next Steps

1. ✅ Configure your dbt profile (profiles.yml)
2. ✅ Test with `dbt debug`
3. ✅ Test inline execution with `<C-CR>`
4. 📝 Set up environment variables for credentials
5. 🔍 Configure preferred target (dev/prod)
6. 📊 Add custom pre-built queries for common use cases

---

Once your database is configured, you can execute queries inline with `<C-CR>` and see results as markdown tables!
