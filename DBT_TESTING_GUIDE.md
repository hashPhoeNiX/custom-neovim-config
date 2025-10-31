# dbt Inline Query Execution - Testing & Troubleshooting Guide

## Quick Start Testing (5 minutes)

### Prerequisites
- [ ] Neovim 0.9+ installed
- [ ] dbt installed: `dbt --version` (should show 1.5+)
- [ ] dbt project configured: `dbt debug` returns success
- [ ] Database connection working: `dbt show --select <model_name>` returns results

### Step 1: Configure Database Connection

```bash
# Test your dbt connection first
cd ~/Projects/custom-neovim/data-dpac-dbt-models
dbt debug
```

If `dbt debug` fails, see [DATABASE_CONFIG.md](DATABASE_CONFIG.md).

### Step 2: Test Basic Keybindings

```bash
# Open a dbt model file
nvim models/staging/stg_customers.sql

# Inside Neovim:
<leader>dr    # Run model with dbtpal
<leader>dt    # Test model
<leader>dv    # Preview compiled SQL in split
```

If any of these fail, check that dbtpal is installed (`:Lazy` should show it).

### Step 3: Test Inline Execution - Power User Method (Ctrl+Enter)

```vim
" Inside your model file, press Ctrl+Enter
<C-CR>
```

**Expected behavior:**
1. Shows "[dbt-power] Executing query (Power User mode)..." notification
2. Compiles the model
3. Wraps SQL with LIMIT clause
4. Executes against database
5. Displays results as markdown table inline

**If it fails:** Check the notifications with `:messages`

### Step 4: Test Alternative Method - dbt show (<leader>ds)

```vim
" Inside your model file, press <leader>ds
<leader>ds
```

**Expected behavior:**
1. Shows "[dbt-power] Executing query (dbt show mode)..." notification
2. Runs `dbt show --select <model>`
3. Displays results as markdown table inline

**If it fails:** Check the notifications with `:messages`

### Step 5: Test Visual Selection Execution

```vim
" Select some SQL lines with visual mode
v
(select some SQL)
<C-CR>
```

**Expected behavior:**
1. Selected SQL is executed against the database
2. Results displayed inline at selection start
3. If no LIMIT present, automatically adds LIMIT 500

---

## Troubleshooting by Symptom

### Symptom: "dbt-power not available" or module not found

**Cause:** dbt-power.nvim plugin not loading

**Solution:**
```vim
:Lazy sync  " Reinstall plugins
:Lazy show dbt-power  " Check plugin status
:lua require('dbt-power').setup({})  " Manually test loading
```

### Symptom: "Not in a dbt project" error

**Cause:** dbt_project.yml not found

**Solution:**
```bash
# Make sure you're in the dbt project directory
cd ~/Projects/custom-neovim/data-dpac-dbt-models

# Check dbt_project.yml exists
ls -la dbt_project.yml

# Run dbt debug to verify setup
dbt debug
```

### Symptom: "Could not determine model name" error

**Cause:** File is not a `.sql` file or not named like a model

**Solution:**
- Only works with files in `models/` directory ending in `.sql`
- Filename becomes the model name (e.g., `stg_customers.sql` → model `stg_customers`)

### Symptom: "No database connection configured"

**Cause:** vim-dadbod is not set up or has no database connection

**Solution:**
```vim
" Open DBUI to configure database
<leader>db

" Or manually add connection to lua config:
vim.g.dbs = {
  dev = 'postgresql://user:pass@localhost/db'
}
```

See [DATABASE_CONFIG.md](DATABASE_CONFIG.md) for detailed setup.

### Symptom: "Compile failed" error

**Cause:** dbt model has syntax errors or missing dependencies

**Solution:**
```bash
# Check compilation manually
cd ~/Projects/custom-neovim/data-dpac-dbt-models
dbt compile --select your_model_name

# Check for:
# 1. Missing ref() or source() calls
# 2. Invalid Jinja syntax
# 3. Undefined macros
```

### Symptom: "dbt show failed" error

**Cause:** Database connection failed or SQL has errors

**Solution:**
```bash
# Test dbt show manually
cd ~/Projects/custom-neovim/data-dpac-dbt-models
dbt show --select your_model_name

# If this fails:
# 1. Check dbt debug output
# 2. Verify database credentials
# 3. Check model SQL for errors
```

### Symptom: Results not displaying (silent failure)

**Cause:** Results exist but aren't being parsed or displayed

**Solution:**
```vim
" Check Neovim messages for parse errors
:messages

" Manually test execution
:lua require('dbt-power.dbt.execute').execute_and_show_inline()

" Check that inline_results module is working
:lua require('dbt-power.ui.inline_results').display_query_results(0, 1, {columns={'a','b'}, rows={{'1','2'}}})
```

### Symptom: Database query fails but dbt show works

**Cause:** Database connection via vim-dadbod is not configured

**Solution:**
This is expected behavior - the fallback chain is:
1. Power User approach (compile → wrap → execute)
2. dbt show as fallback

If Power User fails because vim-dadbod isn't set up, use `<leader>ds` to use dbt show instead.

---

## Full Execution Flow Diagram

```
User presses <C-CR>
        ↓
execute_and_show_inline()
        ↓
        ├─ Get current filename → model name
        ├─ Find dbt project root
        ├─ Clear previous inline results
        │
        ├─→ execute_dbt_model_power_user()
        │   ├─ STEP 1: compile_dbt_model()
        │   │  └─ dbt compile --select <model>
        │   │     └─ Generate SQL in target/compiled/
        │   │
        │   ├─ STEP 2: read_compiled_sql()
        │   │  └─ Read from target/compiled/
        │   │
        │   ├─ STEP 3: wrap_with_limit()
        │   │  └─ SELECT * FROM (...) LIMIT 500
        │   │
        │   └─ STEP 4: execute_wrapped_sql()
        │      └─ execute_via_dadbod()
        │         ├─ Check vim.g.db configured
        │         ├─ Create temp SQL file
        │         ├─ Run: sh -c "DB <db> < <sql> > <csv>"
        │         ├─ Parse CSV results
        │         └─ Callback with results
        │
        │ (If compile fails, fallback to dbt show)
        │
        ├─ parse_dbt_show_results() [if fallback]
        │  └─ Parse piped table output
        │
        ├─ display_query_results()
        │  └─ Format as markdown table
        │  └─ Show inline via extmarks
        │
        └─ Notify user with row count
```

## Testing Checklist

Use this checklist to verify your complete setup:

```
Database Configuration
- [ ] dbt --version shows 1.5+
- [ ] dbt debug succeeds
- [ ] dbt show --select <model> returns data
- [ ] vim.g.dbs configured or :DBUIToggle works

Neovim Plugins
- [ ] :Lazy shows all plugins loaded
- [ ] dbtpal plugin active
- [ ] dbt-power plugin active
- [ ] vim-dadbod plugins active

Basic Model Operations
- [ ] Open model file (.sql in models/ dir)
- [ ] <leader>dr runs model (dbtpal)
- [ ] <leader>dt tests model (dbtpal)
- [ ] <leader>dv shows compiled SQL (dbtpal)
- [ ] <leader>dm opens model picker (dbtpal)

Power User Execution (Ctrl+Enter)
- [ ] <C-CR> shows loading notification
- [ ] Compilation completes
- [ ] SQL wrapping with LIMIT works
- [ ] Database execution succeeds
- [ ] Results display inline as table
- [ ] Row count shown in notification

Alternative Execution (<leader>ds)
- [ ] <leader>ds shows loading notification
- [ ] dbt show command executes
- [ ] Results parse correctly
- [ ] Results display inline

Visual Selection Execution
- [ ] Select SQL lines with v
- [ ] Press <C-CR> to execute selection
- [ ] Results display at selection start
- [ ] LIMIT added automatically if missing

Result Display
- [ ] Results formatted as markdown table
- [ ] Column headers visible
- [ ] Data rows visible
- [ ] Results can be cleared with <leader>dC
```

## Common Workflow Examples

### Example 1: Preview Model Results

```bash
# Open model
nvim models/staging/stg_customers.sql
```

```vim
" Preview compiled SQL
<leader>dv

" Or execute to see results
<C-CR>
```

### Example 2: Develop and Test Model

```vim
" 1. Edit model (you're already in the file)
i
(make edits)
<Esc>:w

" 2. See compiled SQL
<leader>dv

" 3. Run to execute model
<leader>dr

" 4. Run tests
<leader>dt

" 5. See results inline
<C-CR>
```

### Example 3: Ad-hoc Query

```vim
" 1. Open a SQL file or temp buffer
:enew

" 2. Write query
i
SELECT * FROM {{ ref('stg_customers') }} LIMIT 10

" 3. Select and execute
v<C-CR>

" 4. See results inline
```

### Example 4: Debug Model Issues

```vim
" 1. Check compiled SQL
<leader>dv

" 2. If compile failed, check manually
:!dbt compile --select your_model

" 3. If execution failed, check database
<leader>db  \" Opens database browser

" 4. Try dbt show as alternative
<leader>ds
```

## Performance Optimization

### 1. Compilation is slow

**Problem:** `dbt compile --select <model>` takes too long

**Solutions:**
- Use `dbt parse` instead if available (faster)
- Compile once, then use dbt show for previews
- Reduce model dependencies

### 2. Database queries are slow

**Problem:** Inline execution takes a long time

**Solutions:**
- Reduce `max_rows` in config:
  ```lua
  inline_results = {
    max_rows = 100,  -- Instead of 500
  }
  ```
- Add WHERE clauses to limit data
- Execute on smaller warehouse/schema

### 3. Results parsing is slow

**Problem:** Large result sets take long to display

**Solutions:**
- Reduce row limit
- Use simple models without complex output
- Check inline result formatting overhead

## Advanced Testing

### Test Direct Database Execution

```bash
# If vim-dadbod is configured, test it:
# Create temp SQL file
cat > /tmp/test.sql << 'EOF'
SELECT * FROM my_table LIMIT 10
EOF

# Execute via vim-dadbod (requires db configured)
# This tests the underlying database connectivity
```

### Test dbt show Fallback

```bash
# Test dbt show directly
cd ~/Projects/custom-neovim/data-dpac-dbt-models
dbt show --select your_model_name

# This should display results in piped table format
# If it fails, Power User approach will also fail
```

### Test Result Parsing

```lua
-- Test CSV result parser manually in Neovim
:lua
local execute = require('dbt-power.dbt.execute')
local csv = "col1,col2\nval1,val2\nval3,val4"
local results = execute.parse_csv_results(csv)
print(vim.inspect(results))
<CR>
```

## Next Steps If Tests Pass

1. **Customize keybindings** - Edit `lua/plugins/data-tools/dbt.lua`
2. **Adjust max_rows** - Change `inline_results.max_rows` in config
3. **Add database shortcuts** - Create custom commands for frequent queries
4. **Optimize compilation** - Profile slow models with `dbt debug`
5. **Create snippets** - Add vim snippets for common query patterns

## Documentation References

- [DATABASE_CONFIG.md](DATABASE_CONFIG.md) - Database setup details
- [DBT_WORKFLOW.md](DBT_WORKFLOW.md) - Development patterns and workflows
- [DBT_CONFIG_REVIEW.md](DBT_CONFIG_REVIEW.md) - Architecture and fixes
- [dbtpal GitHub](https://github.com/PedramNavid/dbtpal) - dbtpal plugin docs
- [vim-dadbod GitHub](https://github.com/tpope/vim-dadbod) - Database interface

---

**Your dbt+Neovim setup is now complete!** Start by running the Quick Start Testing section above.
