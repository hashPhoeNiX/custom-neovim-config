# dbt in Neovim - Quick Reference

## Keybindings

### Model Execution (dbtpal)

| Key | Action | Notes |
|-----|--------|-------|
| `<leader>dr` | Run current model | Executes `dbt run --select <model>` |
| `<leader>dR` | Run all models | Executes `dbt run` on entire project |
| `<leader>dt` | Test current model | Executes `dbt test --select <model>` |
| `<leader>dT` | Test all models | Executes `dbt test` on entire project |
| `<leader>dc` | Compile current model | Executes `dbt compile --select <model>` |

### Query Execution & Preview

| Key | Action | Notes |
|-----|--------|-------|
| `<C-CR>` | Execute model (Power User) | Compile → Wrap LIMIT → Execute against DB |
| `<leader>ds` | Execute model (dbt show) | Single-step execution via `dbt show` |
| `v<C-CR>` | Execute visual selection | Execute selected SQL against database |
| `<leader>dv` | Preview compiled SQL | Show compiled SQL in split window |
| `<leader>dC` | Clear inline results | Remove displayed results from buffer |

### Navigation & Discovery

| Key | Action | Notes |
|-----|--------|-------|
| `<leader>dm` | Model picker | List all models with Telescope |
| `<leader>db` | Database browser | Browse tables and schemas with DBUI |
| `gf` | Go to ref/source | Navigate to referenced models |

## Command Mode

```vim
" Open specific model
:e models/staging/stg_customers.sql

" Run dbt commands manually
:!dbt compile --select your_model

" Toggle database UI
:DBUIToggle

" Check messages for errors
:messages

" Reload Neovim config
:source ~/.config/nvim/init.lua
```

## Configuration Locations

```
~/.config/nvim/
├── init.lua                          # Main Neovim config
├── lua/
│   ├── config/init.lua              # Core settings
│   └── plugins/data-tools/
│       └── dbt.lua                  # dbt plugin configuration
│
~/.dbt/
├── profiles.yml                     # dbt database credentials
├── dbt_cloud.yml                    # dbt Cloud authentication
└── dbt_cloud/cache.yml              # Cache file (auto-generated)

~/Projects/dbt-power.nvim/
└── lua/dbt-power/
    ├── init.lua                     # Plugin setup
    ├── dbt/execute.lua              # Query execution logic
    ├── ui/inline_results.lua        # Result display formatting
    └── utils/project.lua            # Project detection
```

## Configuration Examples

### Adjust inline result row limit

**File:** `lua/plugins/data-tools/dbt.lua`

```lua
-- Change max_rows in dbt-power config
dbt_power.setup({
  inline_results = {
    max_rows = 100,  -- Show only 100 rows instead of 500
  }
})
```

### Configure database connection

**Option 1: Environment variable**

```bash
# In ~/.zshrc or ~/.bashrc
export DBUI_DEFAULT="postgresql://user:pass@localhost/mydb"
```

**Option 2: Neovim config**

```lua
-- In lua/config/init.lua
vim.g.dbs = {
  dev = 'postgresql://user:pass@localhost/dev_db',
  prod = 'postgresql://user:pass@prod-host/prod_db',
}
```

**Option 3: Interactive (DBUI)**

```vim
:DBUIToggle
" Press 'a' to add connection
" Enter: postgresql://user:pass@localhost/db
```

### Change keybinding

**File:** `lua/plugins/data-tools/dbt.lua`

```lua
-- Example: Change Power User execution to <leader>de
vim.keymap.set("n", "<leader>de", function()
  require("dbt-power.execute").execute_and_show_inline()
end, { desc = "Execute query (Power User mode)" })
```

## Troubleshooting Quick Fix

| Issue | Quick Fix |
|-------|-----------|
| Plugin not loading | `:Lazy sync` then restart Neovim |
| dbt command not found | Install dbt: `brew install dbt-labs/dbt/dbt` |
| "Not in dbt project" | `cd` to directory with `dbt_project.yml` |
| No database connection | `:DBUIToggle` to configure, or set `vim.g.dbs` |
| Results not showing | Check `:messages` for errors |
| Compile failed | Run `dbt compile --select <model>` to debug |
| Slow execution | Reduce `max_rows` or check database load |

## Common Workflows

### Develop a new model

```vim
:e models/staging/my_new_model.sql
i
(write SQL)
<Esc>:w

<leader>dc    # Compile to check syntax
<leader>dr    # Run to execute
<C-CR>        # See results inline
```

### Test query before adding to model

```vim
:e /tmp/query.sql
i
SELECT * FROM my_table LIMIT 10
<Esc>:w

v<C-CR>       # Execute selected SQL
```

### Debug slow model

```vim
<leader>dv    # See compiled SQL
<leader>dm    # Pick dependencies
<leader>dr    # Run with timing
```

### Switch between dev/prod targets

Edit `~/.dbt/profiles.yml` or use:

```vim
:!dbt parse --target prod
<leader>dr    # Now runs against prod
```

## Performance Tips

- **Faster compilation:** Use `dbt parse` instead of `dbt compile`
- **Faster queries:** Reduce `max_rows` to 100
- **Avoid timeouts:** Add WHERE clauses to limit data
- **Cache results:** Use `dbt show` which doesn't materialize views

## File Type Detection

dbt configuration automatically activates for:
- `.sql` files in `models/` directory
- `.yaml` files (for schema definitions)
- `.md` files (for documentation)

Keybindings are only available in these filetypes.

## Debug Commands

```vim
" Check plugin status
:Lazy show dbt-power
:Lazy show dbtpal

" View Neovim logs
:lua print(vim.fn.stdpath('log'))

" Check loaded modules
:lua print(require('package').loaded)

" Test dbt-power manually
:lua require('dbt-power.dbt.execute').execute_and_show_inline()

" Check messages
:messages

" Clear message history
:messages clear
```

## Getting Help

1. **Check documentation:**
   - [DATABASE_CONFIG.md](DATABASE_CONFIG.md) - Database setup
   - [DBT_WORKFLOW.md](DBT_WORKFLOW.md) - Usage patterns
   - [DBT_TESTING_GUIDE.md](DBT_TESTING_GUIDE.md) - Troubleshooting

2. **Check Neovim messages:**
   ```vim
   :messages
   ```

3. **Test manually:**
   ```bash
   dbt --version
   dbt debug
   dbt show --select <model>
   ```

4. **Check plugin status:**
   ```vim
   :Lazy
   ```

## Plugin Versions

These guides are written for:
- **Neovim:** 0.9+
- **dbt:** 1.5+
- **dbtpal:** Latest (from GitHub)
- **vim-dadbod:** Latest
- **vim-dadbod-ui:** Latest
- **dbt-power.nvim:** Latest (custom)

---

## At a Glance

| Goal | Command |
|------|---------|
| Run model | `<leader>dr` |
| Test model | `<leader>dt` |
| See results | `<C-CR>` |
| Preview SQL | `<leader>dv` |
| Execute selection | `v<C-CR>` |
| Browse DB | `<leader>db` |
| Pick model | `<leader>dm` |

**[Full Setup Guide →](DATABASE_CONFIG.md) | [Troubleshooting →](DBT_TESTING_GUIDE.md) | [Workflows →](DBT_WORKFLOW.md)**
