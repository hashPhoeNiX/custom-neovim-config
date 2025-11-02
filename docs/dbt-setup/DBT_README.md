# dbt in Neovim - Complete Setup Guide

Transform your dbt development workflow with **inline query execution**, **model testing**, and **database browsing** - all within Neovim, matching the power of dbt Power User in VS Code.

## What You Get

```
Power User Approach (Ctrl+Enter)
├─ Compile dbt model
├─ Wrap SQL with LIMIT 500
├─ Execute against database
└─ Show results inline as markdown table

Alternative: dbt show (<leader>ds)
├─ Single-step execution
├─ No materialization
└─ Quick preview results

Plus:
├─ Run/test models with <leader>dr, <leader>dt
├─ Browse database schema with <leader>db
├─ Pick models with telescope <leader>dm
├─ Execute SQL selections with v<C-CR>
└─ Preview compiled SQL with <leader>dv
```

## Installation Summary

### 1. Prerequisites (2 minutes)

```bash
# Check Neovim version
nvim --version              # Need 0.9+

# Check dbt version
dbt --version               # Need 1.5+

# Verify dbt project
cd ~/Projects/custom-neovim/data-dpac-dbt-models
dbt debug                   # Should show "All checks passed!"
```

### 2. Plugins (Automatic)

All plugins are configured in `lua/plugins/data-tools/dbt.lua` and will auto-install with Neovim's lazy.nvim:
- ✅ **dbtpal** - Run/test models and compilation
- ✅ **dbt-power.nvim** - Inline query execution (custom)
- ✅ **vim-dadbod** - Database abstraction layer
- ✅ **vim-dadbod-ui** - Database browser UI
- ✅ **vim-dadbod-completion** - SQL autocompletion

### 3. Database Configuration (5 minutes)

Choose ONE of these methods:

**Option A: Environment Variable (Quick)**
```bash
# Add to ~/.zshrc or ~/.bashrc
export DBUI_DEFAULT="postgresql://user:pass@localhost/db"
```

**Option B: Neovim Config (Recommended)**
```lua
-- Add to lua/config/init.lua
vim.g.dbs = {
  dev = 'postgresql://user:pass@localhost/dev_db',
  prod = 'postgresql://user:pass@prod-host/prod_db',
}
```

**Option C: Interactive Setup (Easiest)**
```vim
:DBUIToggle
" Press 'a' to add new connection
" Enter: postgresql://user:pass@localhost/db
```

For Snowflake, BigQuery, or other databases, see [DATABASE_CONFIG.md](#documentation-guide).

### 4. Test Setup (2 minutes)

```bash
# Open a model
nvim ~/Projects/custom-neovim/data-dpac-dbt-models/models/staging/stg_customers.sql

# Inside Neovim:
<leader>dc    # Compile - should succeed
<leader>dr    # Run - should succeed
<C-CR>        # Execute - should show inline results
```

If any step fails, see [Troubleshooting](#troubleshooting).

## Quick Start

### Your First Inline Query

```vim
" In a model file (.sql):

" 1. Preview compiled SQL
<leader>dv

" 2. Execute and see results
<C-CR>

" 3. Results appear inline as a table:
" ┌────────┬────────┐
" │ col1   │ col2   │
" ├────────┼────────┤
" │ value1 │ value2 │
" └────────┴────────┘
" 2 rows
```

### Develop a Model

```vim
:e models/staging/my_model.sql

i
SELECT * FROM {{ ref('base_customers') }}
WHERE created_at > '2024-01-01'
<Esc>:w

<leader>dc    # Compile to check syntax
<leader>dr    # Execute model
<C-CR>        # See results inline
<leader>dt    # Run tests
```

### Quick Ad-hoc Query

```vim
" Select some SQL and execute it:

v
(select SQL with visual mode)
<C-CR>

" Results show right where your selection was
```

## Keybindings at a Glance

### Execution (Most Used)

| Key | Action |
|-----|--------|
| `<C-CR>` | Execute model (Power User: compile → wrap → execute) |
| `<leader>ds` | Execute model (dbt show: single-step) |
| `v<C-CR>` | Execute visual selection |

### dbtpal Integration

| Key | Action |
|-----|--------|
| `<leader>dr` | Run current model |
| `<leader>dR` | Run all models |
| `<leader>dt` | Test current model |
| `<leader>dT` | Test all models |
| `<leader>dc` | Compile current model |
| `<leader>dv` | Preview compiled SQL |
| `<leader>dm` | Pick model with telescope |

### Database & Results

| Key | Action |
|-----|--------|
| `<leader>db` | Toggle database browser (DBUI) |
| `<leader>dC` | Clear inline results |

**[See full keybindings →](DBT_QUICK_REFERENCE.md#keybindings)**

## Documentation Guide

Start here based on your situation:

### 🚀 Getting Started
- **[DBT_QUICK_REFERENCE.md](DBT_QUICK_REFERENCE.md)** - Keybindings and quick commands
- **[DATABASE_CONFIG.md](DATABASE_CONFIG.md)** - Database setup (Snowflake/PostgreSQL/BigQuery)
- **[DBT_WORKFLOW.md](DBT_WORKFLOW.md)** - Development patterns and best practices

### 🧪 Testing & Troubleshooting
- **[DBT_TESTING_GUIDE.md](DBT_TESTING_GUIDE.md)** - 5-minute test checklist + troubleshooting
- **[DBT_CONFIG_REVIEW.md](DBT_CONFIG_REVIEW.md)** - Architecture overview and what was fixed

### 📋 Navigation
- **[DBT_README.md](DBT_README.md)** - This file (overview)

## Troubleshooting

### Most Common Issues

**Issue:** `<C-CR>` does nothing
- **Check:** `:messages` to see error
- **Solution:** See [DBT_TESTING_GUIDE.md](DBT_TESTING_GUIDE.md#troubleshooting-by-symptom)

**Issue:** "Not in a dbt project"
- **Check:** `dbt debug` - should succeed
- **Solution:** Make sure you're in directory with `dbt_project.yml`

**Issue:** "No database connection configured"
- **Check:** `:DBUIToggle` - can you see a connection?
- **Solution:** Add one with 'a' key, or set `vim.g.dbs`

**Issue:** Compilation fails
- **Check:** `dbt compile --select your_model` manually
- **Solution:** Fix SQL errors or missing dependencies

For more help, see [Troubleshooting Guide](DBT_TESTING_GUIDE.md#troubleshooting-by-symptom).

## How It Works

### The Three Methods

#### Method 1: Power User Approach (Recommended for Development)
```
Ctrl+Enter
  ↓
dbt compile --select <model>  (generates SQL from Jinja)
  ↓
Read from target/compiled/    (get compiled SQL)
  ↓
Wrap: SELECT * FROM (...) LIMIT 500  (safe preview)
  ↓
Execute against database      (get actual results)
  ↓
Display inline               (show as markdown table)
```

**Pros:**
- Matches dbt Power User VS Code extension
- Handles all dbt features (ref, source, macros)
- Results from actual database execution
- Safe LIMIT wrapping

**Cons:**
- Requires database connection configured
- Slower (two-step: compile + execute)

#### Method 2: dbt show Approach (Quick Preview)
```
<leader>ds
  ↓
dbt show --select <model>
  ↓
Parse piped table output
  ↓
Display inline
```

**Pros:**
- Single command (faster)
- Works with all dbt features
- No database configuration needed

**Cons:**
- No materialization
- Limited to what dbt show returns

#### Method 3: Visual Selection (Ad-hoc Queries)
```
v<C-CR>
  ↓
Get selected SQL
  ↓
Add LIMIT if missing
  ↓
Execute against database
  ↓
Display inline
```

**Pros:**
- Test SQL before adding to models
- Full SQL customization
- Fast iteration

**Cons:**
- Requires database connection
- Manual LIMIT management

## System Architecture

```
Your Neovim Config
├─ lua/plugins/data-tools/dbt.lua          (Plugin config)
│
├─ Plugins (auto-installed)
│ ├─ dbtpal                                (Model run/test/compile)
│ ├─ dbt-power.nvim (custom)               (Inline execution)
│ │ ├─ execute.lua                         (3-step execution)
│ │ ├─ inline_results.lua                  (Result display)
│ │ └─ project.lua                         (Project detection)
│ ├─ vim-dadbod                            (Database interface)
│ └─ vim-dadbod-ui                         (Database browser)
│
├─ External Tools
│ ├─ dbt (CLI)                             (Compilation & execution)
│ ├─ Your database                         (Snowflake/PostgreSQL/etc)
│ └─ dbt_project.yml                       (dbt config)
│
└─ Configuration Files
  └─ ~/.dbt/profiles.yml                   (Database credentials)
```

## Example: Complete Workflow

```bash
# 1. Setup (one-time)
cd ~/Projects/custom-neovim
mkdir -p ~/.dbt
cat > ~/.dbt/profiles.yml << 'EOF'
my_project:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      user: myuser
      password: mypass
      database: mydb
      schema: dev
EOF

# 2. Test
dbt debug  # Should succeed

# 3. Open model
nvim data-dpac-dbt-models/models/staging/stg_customers.sql

# 4. In Neovim:
# - <leader>dc  - Compile to check syntax
# - <leader>dr  - Run model
# - <C-CR>      - See results inline
# - <leader>dt  - Test
```

## Customization

### Change Keybindings

Edit `lua/plugins/data-tools/dbt.lua`:

```lua
-- Change Ctrl+Enter to something else:
vim.keymap.set("n", "<leader>de", function()
  require("dbt-power.execute").execute_and_show_inline()
end, { desc = "Execute query" })
```

### Adjust Result Limit

```lua
-- In dbt-power config:
dbt_power.setup({
  inline_results = {
    max_rows = 100,  -- Instead of 500
  }
})
```

### Add Custom Commands

```lua
-- Add to lua/config/init.lua:
vim.api.nvim_create_user_command("DbtRunAll", function()
  vim.fn.system("dbt run")
  vim.notify("dbt run completed")
end, {})

-- Then use:
:DbtRunAll
```

## Performance

- **Compile:** ~1-2 seconds (dbt compile)
- **Execute:** ~0.5-5 seconds (depends on database)
- **Display:** <100ms (markdown table formatting)
- **Total:** 1.5-7 seconds per execution

For faster iterations, use `<leader>ds` (dbt show) which skips the database execution step.

## Comparing to Alternatives

| Feature | dbt Power User (VS Code) | dbt-power (Neovim) |
|---------|--------------------------|-------------------|
| Run/test models | ✅ | ✅ `<leader>dr`, `<leader>dt` |
| Inline results | ✅ | ✅ `<C-CR>` |
| Compiled preview | ✅ | ✅ `<leader>dv` |
| Model picker | ✅ | ✅ `<leader>dm` |
| Database browser | ✅ | ✅ `<leader>db` |
| Navigation | ✅ | ✅ `gf` on refs |
| SQL autocomplete | ✅ | ✅ (via dadbod) |
| Keyboard-driven | ⚠️ Partial | ✅ Full |
| Performance | Good | Excellent |
| Price | Free (but VS Code) | Free + your editor |

## Requirements

- **Neovim** 0.9+
- **dbt** 1.5+ (get via `brew install dbt-labs/dbt/dbt`)
- **Database** configured (Snowflake, PostgreSQL, BigQuery, etc)
- **dbt project** with proper `dbt_project.yml` and `profiles.yml`

## Files Overview

### User-Facing Documentation
- `DBT_README.md` - This file (overview)
- `DBT_QUICK_REFERENCE.md` - Keybindings and commands
- `DATABASE_CONFIG.md` - Database setup guide
- `DBT_WORKFLOW.md` - Development patterns
- `DBT_TESTING_GUIDE.md` - Testing and troubleshooting
- `DBT_CONFIG_REVIEW.md` - Architecture and what was fixed

### Configuration Files
- `lua/plugins/data-tools/dbt.lua` - Plugin setup and keybindings
- `~/.dbt/profiles.yml` - Database credentials (you create this)

### Plugin Files (in dbt-power.nvim)
- `lua/dbt-power/dbt/execute.lua` - Core execution logic
- `lua/dbt-power/ui/inline_results.lua` - Result display
- `lua/dbt-power/utils/project.lua` - Project utilities

## Getting Help

1. **Check the docs:**
   - [DBT_QUICK_REFERENCE.md](DBT_QUICK_REFERENCE.md) for commands
   - [DBT_TESTING_GUIDE.md](DBT_TESTING_GUIDE.md) for troubleshooting

2. **Check Neovim messages:**
   ```vim
   :messages
   ```

3. **Test manually:**
   ```bash
   dbt debug
   dbt compile --select your_model
   dbt show --select your_model
   ```

4. **Check plugins:**
   ```vim
   :Lazy
   ```

## What's Next?

1. ✅ **Complete prerequisite setup** - Follow DATABASE_CONFIG.md
2. ✅ **Test your installation** - Use DBT_TESTING_GUIDE.md
3. ✅ **Learn the workflow** - Read DBT_WORKFLOW.md
4. ✅ **Customize** - Adjust keybindings in dbt.lua
5. 🚀 **Start developing** - Open a model and execute with `<C-CR>`

## Status

This setup is **production-ready** and includes:
- ✅ Full Power User approach implementation
- ✅ Fallback to dbt show
- ✅ Visual selection execution
- ✅ Multiple result format parsers
- ✅ Comprehensive documentation
- ✅ Testing and troubleshooting guides

## Questions?

See [DBT_TESTING_GUIDE.md](DBT_TESTING_GUIDE.md#troubleshooting-by-symptom) for symptoms and solutions.

---

**Ready to level up your dbt workflow? Start with [DATABASE_CONFIG.md](DATABASE_CONFIG.md) for a 5-minute setup!**
