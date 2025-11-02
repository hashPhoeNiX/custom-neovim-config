# Recent Improvements - Loading Messages and Buffer Formatting

## What Changed

### 1. Loading Message While Waiting ✅

**Problem:** Execution takes minutes but no feedback shown to user

**Solution:**
- Show persistent notification while executing
- Display model name: `[dbt-power] Executing my_model...`
- Notification stays until results arrive
- Works for both `<leader>ds` (inline) and `<leader>dS` (buffer)

**How it works:**
```vim
<leader>dS
" You see: [dbt-power] Executing stg_customers...
" (notification persists for 1-5 minutes while waiting)
" Results display when ready
```

### 2. Clean Markdown Table Formatting ✅

**Problem:** Buffer output wasn't formatted as clean as inline version

**Solution:**
- Use identical markdown table format for both
- Same box-drawing characters: `│ ├─ ─┼─ ─┤ └─ ─┴─ ─┘`
- Proper column alignment
- Long values truncated (50 char default)
- Show column headers with separator line
- Display row count summary

**Before (buffer was messy):**
```
ID NAME CREATED_AT
1 Active 2017-09-29
2 Pending 2017-09-29
```

**After (clean markdown table):**
```
│ ID │ NAME        │          CREATED_AT │
├─────┼─────────────┼────────────────────┤
│ 1   │ Active      │ 2017-09-29 03:30:05│
│ 2   │ Pending     │ 2017-09-29 03:30:05│
└─────┴─────────────┴────────────────────┘
7 rows
```

## Updated Behavior

### Inline Execution (`<leader>ds`)
```vim
<leader>ds
" [dbt-power] Executing stg_customers...  ← Loading message
" (waiting...)
" Results display inline as markdown table
```

### Buffer Execution (`<leader>dS`)
```vim
<leader>dS
" [dbt-power] Executing stg_customers...  ← Loading message
" (waiting...)
" [Results open in bottom split with clean formatting]
```

### CTE Preview (`<leader>dq`)
```vim
<leader>dq
" Select CTE to preview:
#   > customer_base
"     customer_orders
# (after selection)
# [dbt-power] Executing customer_base...  ← Loading message
# (waiting...)
# [Results show in buffer]
```

## Implementation Details

### New Functions in buffer_output.lua

**show_loading(message)**
- Creates persistent notification
- Doesn't auto-dismiss until complete
- Shows model name being executed

**update_loading(message)**
- Updates existing loading notification
- For potential progress updates

**clear_loading()**
- Removes the loading notification
- Called when results arrive

**format_results_as_markdown(results, title)**
- Formats results as markdown table
- Matches inline version formatting
- Handles NULL values
- Truncates long strings

**truncate_string(str, max_width)**
- Limits display width per column
- Default 50 characters
- Adds "..." for truncated values

### Modified Files

**dbt-power.nvim/lua/dbt-power/ui/buffer_output.lua**
- Added loading message functions
- Added markdown formatting function
- Improved table presentation

**dbt-power.nvim/lua/dbt-power/dbt/execute.lua**
- Show loading before execution
- Clear loading when results arrive
- Improved notifications

## Configuration

### Customize Table Column Width

Edit `dbt-power.nvim/lua/dbt-power/ui/buffer_output.lua`:

```lua
-- Line 97: Change max_col_width
local max_col_width = 50    -- Default, increase for wider columns
```

Options:
- `30` - Narrow columns, more fit on screen
- `50` - Default, good balance
- `80` - Wide columns, fewer visible
- `100` - Very wide, for detailed data

## Visual Comparison

### Inline Results (with loading)
```
[dbt-power] Executing stg_customers...  ← Notification shown
(waiting 1-5 minutes...)
│ ID │ NAME        │          CREATED_AT │  ← Results appear inline
├─────┼─────────────┼────────────────────┤
│ 1   │ Active      │ 2017-09-29 03:30:05│
│ 2   │ Pending     │ 2017-09-29 03:30:05│
7 rows
```

### Buffer Results (with loading)
```
[dbt-power] Executing stg_customers...  ← Notification shown
(waiting 1-5 minutes...)
Model: stg_customers                    ← Buffer opens with title

│ ID │ NAME        │          CREATED_AT │
├─────┼─────────────┼────────────────────┤
│ 1   │ Active      │ 2017-09-29 03:30:05│
│ 2   │ Pending     │ 2017-09-29 03:30:05│
│ 3   │ Deleted     │ 2017-09-29 03:30:05│
│ 4   │ Suspended   │ 2017-09-29 03:30:05│
│ 5   │ Expired     │ 2017-09-29 03:30:05│
│ 6   │ Deactivated │ 2017-10-30 13:33:22│
│ 7   │ Delayed     │ 2018-04-26 17:25:32│
└─────┴─────────────┴────────────────────┘
7 rows
```

## Benefits

✅ **User Feedback** - Know system is working during long waits
✅ **Clean Formatting** - Professional looking results
✅ **Consistency** - Inline and buffer look the same
✅ **Readability** - Easy to scan data
✅ **Truncation** - Long values don't break layout

## Git Commits

- `2c5baf9` - Add loading message and improve buffer formatting

## Testing

Try it:
```bash
# Restart Neovim
pkill nvim
nvim ~/Projects/custom-neovim/data-dpac-dbt-models/models/staging/stg_customers.sql
```

```vim
<leader>dS    " Watch loading message, see formatted results
<leader>ds    " Quick inline check
<leader>dq    " CTE preview with loading message
```

---

**These improvements make the Neovim setup feel responsive and professional!** 🚀
