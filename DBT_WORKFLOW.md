# dbt Development Workflow in Neovim

A comprehensive guide to the optimal development workflow for dbt in Neovim, closely matching the dbt Power User extension for VS Code.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Complete Development Workflow](#complete-development-workflow)
3. [Model Execution](#model-execution)
4. [Inline Query Results](#inline-query-results)
5. [Navigation & Discovery](#navigation--discovery)
6. [Testing & Validation](#testing--validation)
7. [Common Patterns](#common-patterns)
8. [Performance Optimization](#performance-optimization)

---

## Quick Start

### Prerequisites

1. **dbt Installed**: `dbt --version` should show v1.5+
2. **Database Configured**: Run `dbt debug` - should show success
3. **Neovim Loaded**: All plugins loaded (check with `:Lazy`)

### First 5 Minutes

```bash
# 1. Navigate to your dbt project
cd ~/Projects/custom-neovim/data-dpac-dbt-models

# 2. Open a model file in Neovim
nvim models/staging/stg_customers.sql

# 3. In Neovim - Run the model
<leader>dr
" Wait for: ✓ stg_customers completed in X.Xs

# 4. Preview compiled SQL
<leader>dv
" Split shows the actual SQL that will run

# 5. Execute inline
<C-CR>
" Below your cursor, see markdown table with results
```

---

## Complete Development Workflow

### Phase 1: Model Creation

```
1. Create new model file or open existing one
   nvim models/staging/stg_orders.sql

2. Write SQL with dbt syntax:
   ┌────────────────────────────────────────┐
   │ -- Description                         │
   │ {{ config(materialized = 'view') }}    │
   │                                        │
   │ SELECT                                 │
   │   order_id,                            │
   │   customer_id,                         │
   │   {{ dbt_utils.generate_surrogate_key( │
   │     ['order_id', 'customer_id']        │
   │   ) }} as order_key                    │
   │ FROM {{ source('raw', 'orders') }}     │
   │ WHERE status IN ('completed')          │
   └────────────────────────────────────────┘

   [Autocomplete suggestions appear for ref() and source()]

3. Preview compiled SQL
   <leader>dv

   [Right split shows resolved SQL without Jinja]
```

### Phase 2: Development & Testing

```
4. Execute current model
   <leader>dr

   [See output]:
   ✓ stg_orders: created view
   Done. [1 complete in 1.23s]

5. View results inline
   Position cursor at end of SELECT
   <C-CR>

   [Results appear below]:
   ┌──────────┬──────────────┬───────────┐
   │ order_id │ customer_id  │ order_key │
   ├──────────┼──────────────┼───────────┤
   │ 1        │ 100          │ abc123... │
   │ 2        │ 101          │ def456... │
   └──────────┴──────────────┴───────────┘
   2 rows

6. Iterate: Make changes and repeat steps 3-5
   [Edit] → <leader>dv → <leader>dr → <C-CR>
```

### Phase 3: Testing

```
7. Run dbt tests
   <leader>dt

   [Output]:
   Testing dbt project
   ✓ not_null_orders_order_id
   ✓ unique_orders_order_id
   ✓ relationships_orders_customer_id

   Done. [3 passed in 0.45s]

8. Run all tests
   <leader>dT
```

### Phase 4: Review & Commit

```
9. Review compiled SQL one more time
   <leader>dv

10. Preview full lineage (optional)
    <leader>dm  " Open model picker
    " Search and navigate to dependent models

11. Commit your changes
    :! git add models/staging/stg_orders.sql
    :! git commit -m "Add stg_orders model with tests"
```

---

## Model Execution

### Running Models

| Action | Keybinding | Result |
|--------|-----------|--------|
| Run current model | `<leader>dr` | Creates/updates table/view in DB |
| Test current model | `<leader>dt` | Runs tests for this model |
| Compile current model | `<leader>dc` | Shows compiled SQL |
| Run all models | `<leader>dR` | Full dbt run |
| Test all models | `<leader>dT` | Runs all tests |

### Understanding Output

```
✓ indicates SUCCESS (green)
✗ indicates FAILURE (red)

Example output:
  ✓ stg_customers: created view in 0.45s
  ✓ fct_orders: created table in 2.30s

Done. [2 complete in 2.75s]
```

### Handling Errors

```
If <leader>dr shows an error:

1. Check the error message in command output
2. Review compiled SQL: <leader>dv
3. Look for issues in:
   - Missing source/ref definitions
   - Invalid Jinja syntax
   - Data type mismatches
   - Circular dependencies

4. Fix and run again: <leader>dr
```

---

## Inline Query Results

### Executing Queries

#### Current Model
```vim
" Cursor anywhere in model file
<C-CR>

" Executes the entire model with LIMIT 500
" Results appear below cursor
```

#### Visual Selection
```vim
" Select SQL in visual mode
v
" Select lines...
<C-CR>

" Executes only the selected SQL with LIMIT 500
```

#### Partial Model
```sql
-- In your model file:
SELECT order_id, customer_id
FROM {{ ref('stg_orders') }}
WHERE status = 'completed'
LIMIT 10  ← Cursor here
<C-CR>
" Executes this SELECT with your explicit LIMIT
```

### Understanding Results

The results table shows:
- **Column headers**: Bolded, with truncation indicator if wide
- **Row count**: "X rows" or "Showing X of Y rows" if limited
- **Format**: Markdown table for easy copying

```
┌──────────┬──────────────┬────────────┐
│ order_id │ customer_id  │ created_at │
├──────────┼──────────────┼────────────┤
│ 1        │ 100          │ 2024-01-01 │
│ 2        │ 101          │ 2024-01-02 │
└──────────┴──────────────┴────────────┘
2 rows
```

### Clearing Results

```vim
" Clear all inline results in current buffer
<leader>dC

" Clear individual result by deleting its lines
" Position cursor on result and press dd
```

### Limitations & Workarounds

| Issue | Cause | Workaround |
|-------|-------|-----------|
| "Query execution failed" | Database connection not configured | See [DATABASE_CONFIG.md](DATABASE_CONFIG.md) |
| Results don't show | dbt query command not available | Requires dbt >= 1.5 |
| Slow execution | Large result set or complex query | Add LIMIT or WHERE clause |
| NULL values showing as NULL | Normal behavior | Use COALESCE() in query if needed |

---

## Navigation & Discovery

### Finding Models

```vim
" Fuzzy find models in your project
<leader>dm

" Type to search:
  stg_cust...
  └─ stg_customers.sql ✓

" Press Enter to open
```

### Following References

```vim
" With cursor on 'stg_customers' in:
  FROM {{ ref('stg_customers') }}

" Press gf to jump to that model file
" This opens models/staging/stg_customers.sql
```

### Exploring Database

```vim
" Toggle database browser
<leader>db

" Browse structure:
  🏢 dev (Snowflake)
     🗂️  staging
        📋 stg_customers
        📋 stg_orders
     🗂️  public
        📊 raw_customers

" Select table and press Enter to see data
```

### Model Documentation

```vim
" View model documentation (if configured)
" In Neovim, search for the description field in dbt_project.yml
```

---

## Testing & Validation

### dbt Built-in Tests

```yaml
# In models/staging/stg_customers.yml:
models:
  - name: stg_customers
    columns:
      - name: customer_id
        tests:
          - unique
          - not_null
      - name: email
        tests:
          - unique
```

### Running Tests

```vim
" Test current model
<leader>dt

" Test all models
<leader>dT

" See results:
  ✓ not_null_stg_customers_customer_id
  ✓ unique_stg_customers_customer_id
  ✗ unique_stg_customers_email

  "email" has duplicate values:
  - alice@example.com (2 occurrences)

Done. [3 tests run]
```

### Custom Tests

Create in `tests/` directory:

```sql
-- tests/check_customers_valid.sql
SELECT *
FROM {{ ref('stg_customers') }}
WHERE customer_id IS NULL
  OR email NOT LIKE '%@%.%'
```

Run with `<leader>dT` - fails if query returns any rows.

---

## Common Patterns

### Pattern 1: Quick Data Exploration

```vim
" Need to understand a table?

1. Open model file
<C-CR>

" See first 500 rows, understand structure

2. Filter and refine
   SELECT * FROM {{ ref('stg_customers') }}
   WHERE status = 'active'
<C-CR>

" Verify data quality
```

### Pattern 2: Building a Complex Model

```vim
1. Start with source data
   FROM {{ source('raw', 'events') }}

2. Add first transformation step
<C-CR>  " Run to verify

3. Add next transformation
<C-CR>  " Verify intermediate results

4. Repeat until complete
<C-CR>

5. Add tests and documentation
<leader>dt

6. Final run
<leader>dr
```

### Pattern 3: Debugging Failed Models

```vim
1. Model failed during <leader>dr?

2. Check compiled SQL
<leader>dv
   " Look for unexpected Jinja expansions
   " Verify table names are correct

3. Test problematic part
   SELECT * FROM {{ ref('dependency_model') }} LIMIT 1
<C-CR>
   " If this fails, dependency has issue

4. Navigate to dependency
gf  " on model name

5. Fix dependency first
<leader>dr

6. Return to original model
<C-CR>  " Then <leader>dr
```

### Pattern 4: Comparing Dev vs Prod

```vim
1. Query staging model
   SELECT COUNT(*) FROM {{ ref('stg_customers') }}
<C-CR>

2. Switch to prod profile
:DbSwitch prod

3. Query production model
   SELECT COUNT(*) FROM {{ ref('stg_customers') }}
<C-CR>

4. Compare row counts
```

### Pattern 5: Building Documentation

```vim
1. Add YAML documentation
" In models/staging/schema.yml:
models:
  - name: stg_customers
    description: |
      Deduplicated customer records with enhanced attributes

    columns:
      - name: customer_id
        description: Unique customer identifier
        tests:
          - unique
          - not_null

2. Run tests to validate
<leader>dT

3. Generate docs
:! dbt docs generate

4. View docs
:! dbt docs serve
" Opens https://localhost:8000
```

---

## Performance Optimization

### Optimize Query Execution

```sql
-- ❌ SLOW: Unfiltered source
SELECT *
FROM {{ source('raw', 'events') }}

-- ✅ FAST: Pre-filtered in model
SELECT *
FROM {{ source('raw', 'events') }}
WHERE event_date >= '2024-01-01'
  AND event_type IN ('click', 'purchase')
LIMIT 100
```

### Use dbt Features

```sql
-- ❌ SLOW: Manual de-duplication
SELECT DISTINCT *
FROM raw_data

-- ✅ FAST: dbt built-in macro
SELECT *
FROM {{ dbt_utils.group_by(n=10) }}

-- ✅ FAST: Incremental models
{{ config(
  materialized='incremental',
  unique_key='id',
  on_schema_change='fail'
) }}

SELECT * FROM source
{% if execute and this.exists %}
  WHERE created_at > (SELECT MAX(created_at) FROM {{ this }})
{% endif %}
```

### Limit Result Sets

```sql
-- When using <C-CR>, results are auto-limited
-- But you can add explicit LIMIT for faster execution

SELECT *
FROM {{ ref('large_table') }}
LIMIT 100  -- Much faster than LIMIT 500
<C-CR>
```

### Use Database Features

```sql
-- Push computation to database
SELECT
  customer_id,
  COUNT(*) as order_count,      -- DB aggregates
  AVG(amount) as avg_order_amt   -- Not Neovim
FROM {{ ref('orders') }}
GROUP BY customer_id
<C-CR>
```

---

## Workflow Customization

### Customize Key Bindings

Edit `lua/plugins/data-tools/dbt.lua`:

```lua
-- Change run binding
vim.keymap.set("n", "<leader>r", "<cmd>lua require('dbtpal').run_model()<cr>", opts)

-- Add custom binding for your workflow
vim.keymap.set("n", "<leader>tx", "<cmd>lua require('dbtpal').test_model()<cr>", opts)
```

### Add Custom Commands

```lua
-- In dbt.lua config section:
vim.api.nvim_create_user_command("DbtRunAndTest", function()
  require('dbtpal').run_model()
  vim.defer_fn(function()
    require('dbtpal').test_model()
  end, 2000)  -- Wait 2 seconds for run to complete
end, {})

-- Use as: :DbtRunAndTest
```

### Create Model Templates

```bash
# Create template for new models
cat > ~/.config/nvim/templates/dbt_model.sql << 'EOF'
-- {{ name }}
-- Description:

{{ config(
  materialized = 'view',
  tags = ['daily']
) }}

SELECT
  *
FROM {{ source('', '') }}
EOF
```

---

## Comparing to dbt Power User (VS Code)

| Feature | Neovim | VS Code |
|---------|--------|---------|
| Run/test models | ✅ Same | ✅ Same |
| Inline results | ✅ Via <C-CR> | ✅ Via button |
| Compiled preview | ✅ <leader>dv | ✅ Live |
| Model picker | ✅ <leader>dm | ✅ Command palette |
| Database browser | ✅ <leader>db | ✅ Built-in |
| Tests | ✅ <leader>dt | ✅ Built-in |
| Speed | ✅✅ Faster | ✅ Slower UI |
| Keyboard-driven | ✅✅ Yes | ✅ Hybrid |
| Customization | ✅✅ Full | ⚠️ Limited |

**Key Advantage**: Stay in Neovim, no context switching

---

## Troubleshooting Quick Reference

| Problem | Solution |
|---------|----------|
| Models won't run | `dbt debug` - check profile config |
| Inline results fail | `dbt query` not available - upgrade dbt |
| Slow execution | Add LIMIT, check model dependencies |
| Compilation fails | `<leader>dv` - check error in compiled SQL |
| Tests fail | `<leader>dT` - debug test failures |
| Database not found | See [DATABASE_CONFIG.md](DATABASE_CONFIG.md) |

---

## Resources

- Full Setup Guide: [DBT_SETUP_GUIDE.md](DBT_SETUP_GUIDE.md)
- Database Configuration: [DATABASE_CONFIG.md](DATABASE_CONFIG.md)
- Keybindings Reference: [KEYBINDINGS_UPDATE.md](KEYBINDINGS_UPDATE.md)
- dbt Documentation: https://docs.getdbt.com/

---

**Next Steps**: Start with a simple model, run it, execute inline results, and iterate!
