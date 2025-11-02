# Buffer Output and CTE Preview Features

## Overview

Added VS Code dbt Power User-like functionality for viewing full result sets and previewing CTEs (Common Table Expressions).

## New Features

### 1. Buffer Output for Full Results

**Keymap:** `<leader>dS` (capital S = "Show in buffer")

**What it does:**
- Executes the current dbt model using `dbt show`
- Displays results in a **bottom split window** (not inline)
- Formats as a clean table with column headers
- Shows entire result set up to `max_rows` limit (default 500)

**When to use:**
- Need to see full result set
- Want results in separate window
- Better for large datasets

**How to close:**
- Press `q` in the results buffer
- Press `Esc` in the results buffer
- Click in results buffer and execute another command

**Example:**
```vim
:e models/staging/stg_customers.sql
<leader>dS    " View all customer results in buffer
```

### 2. Inline Results (Keep Existing)

**Keymap:** `<leader>ds` (lowercase s = inline)

**What it does:**
- Executes the current dbt model using `dbt show`
- Displays results as markdown table **inline** at cursor position
- Good for quick previews without window splitting

**When to use:**
- Quick peeking at data
- Don't want to lose current window layout
- Small result sets

**Example:**
```vim
:e models/staging/stg_customers.sql
<leader>ds    " View inline results at cursor
```

### 3. CTE Preview Picker

**Keymap:** `<leader>dq` (q = query/cte)

**What it does:**
- Lists all CTEs (WITH clauses) in the current model
- Pick one to preview
- Executes just that CTE with `SELECT *`
- Shows results in buffer output
- Like VS Code dbt Power User extension

**When to use:**
- Debug intermediate transformations
- Verify CTE logic
- Understand data flow through model

**How it works:**
```sql
-- Example model with multiple CTEs
WITH customer_base AS (
  SELECT id, name FROM raw_customers
),
customer_orders AS (
  SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id
)
SELECT * FROM customer_base
JOIN customer_orders ON customer_base.id = customer_orders.customer_id
```

When you press `<leader>dq`:
```
Select CTE to preview:
  > customer_base
    customer_orders
```

Select `customer_base` to see all customers without the join.

**Example:**
```vim
:e models/staging/stg_customers.sql
<leader>dq    " Show CTE picker
              " Select a CTE from the list
              " Results display in buffer
```

## Keymap Reference

| Keymap | Action | Display | Notes |
|--------|--------|---------|-------|
| `<leader>ds` | Execute model | Inline | Quick preview, no window split |
| `<leader>dS` | Execute model | Buffer | Full results in bottom split |
| `<leader>dq` | Preview CTE | Buffer | Pick a CTE to preview |
| `<leader>dr` | Run model | (dbtpal) | Execute in dbt |
| `<leader>dt` | Test model | (dbtpal) | Run dbt tests |
| `<leader>dv` | Preview SQL | Split | Show compiled SQL |
| `<leader>db` | Database | (DBUI) | Browse tables |
| `<leader>dC` | Clear results | Inline | Remove inline display |

## Configuration

### Max Rows Limit

Edit `lua/plugins/data-tools/dbt.lua`:

```lua
inline_results = {
  max_rows = 500,    -- Change this number
}
```

This controls how many rows are displayed for:
- Buffer output (`<leader>dS`)
- CTE preview (`<leader>dq`)
- dbt show execution

Values:
- `100` - Show 100 rows
- `500` - Show 500 rows (default)
- `1000` - Show 1000 rows
- `-1` - Show all rows (be careful with large tables!)

## Implementation Details

### New Files

1. **`dbt-power.nvim/lua/dbt-power/ui/buffer_output.lua`**
   - Buffer window management
   - Table formatting
   - Open/close functions

2. **`dbt-power.nvim/lua/dbt-power/dbt/cte_preview.lua`**
   - CTE extraction from SQL
   - CTE execution via dbt show --inline
   - Picker interface (Telescope or vim.ui.select)

3. **`dbt-power.nvim/lua/dbt-power/dbt/execute.lua`** (updated)
   - New function: `execute_with_dbt_show_buffer()`

### Keymaps

Non-overlapping design:
- **Inline vs Buffer:** `ds` (lowercase) vs `dS` (uppercase)
- **CTE Preview:** `dq` (different letter entirely)
- **No conflicts** with dbtpal keybindings

## Workflow Examples

### Example 1: Quick Data Check with Inline

```vim
:e models/staging/stg_customers.sql
<leader>ds    " See first 5-10 rows inline
```

### Example 2: View Full Results

```vim
:e models/staging/stg_customers.sql
<leader>dS    " See all 500 rows in split
              " Scroll through results
q              " Close buffer when done
```

### Example 3: Debug CTE Logic

```vim
:e models/fact_orders.sql
<leader>dq    " Open CTE picker
              " See: base_customers, customer_orders, final_join
              " Select 'customer_orders'
              " View 500 rows from that CTE
q              " Close when done
```

### Example 4: Full Development Cycle

```vim
:e models/staging/stg_customers.sql

" Preview inline
<leader>ds

" See full results
<leader>dS

" Debug intermediate step
<leader>dq

" Check compiled SQL
<leader>dv

" Run the model in dbt
<leader>dr
```

## Troubleshooting

### Buffer won't display results

Check `:messages` for errors. Could be:
- dbt show failed (check SQL syntax)
- No data returned (valid result)
- Parsing error

### CTE picker doesn't show CTEs

Make sure:
- Model has `WITH` clause
- CTE names are valid Lua identifiers (letters, numbers, underscore)
- No complex nested WITH statements

### Results look cut off

- Increase `max_column_width` in config
- Adjust buffer height (currently 15 lines, can modify in `buffer_output.lua`)

### Inline vs Buffer showing same data?

Both use `dbt show --limit X`. Difference is just display:
- Inline: Markdown table at cursor
- Buffer: Formatted table in split window

## Comparison to VS Code dbt Power User

| Feature | VS Code | Neovim |
|---------|---------|--------|
| Execute model | ✅ | ✅ `<leader>ds` (inline) or `<leader>dS` (buffer) |
| Preview CTE | ✅ With picker | ✅ `<leader>dq` (picker included) |
| View results | Inline | ✅ Both inline and buffer |
| Close results | Auto-fade | `q` or `Esc` in buffer |
| Multiple CTEs | ✅ Picker | ✅ Picker (Telescope or vim.ui.select) |

Neovim actually has **better CTE preview** - you choose display method!

## Future Enhancements

Potential additions:
- Toggle default between inline/buffer
- Customize buffer height/position
- Add result pagination
- Export results to file
- Compare CTE outputs side-by-side

---

**Happy data debugging!** 🚀
