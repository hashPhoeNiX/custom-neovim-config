# Fix for E5108 Error: execute_with_dbt_show_command nil value

## The Problem

When starting Neovim or pressing `<leader>ds`, you got this error:

```
E5108: Error executing lua: ...source/lua/plugins/data-tools/dbt.lua:50:
attempt to call field 'execute_with_dbt_show_command' (a nil value)
```

## Root Cause

The dbt-power.nvim plugin has two execute.lua files:
1. `dbt-power.nvim/lua/dbt-power/execute.lua` - **Convenience module wrapper**
2. `dbt-power.nvim/lua/dbt-power/dbt/execute.lua` - **Actual implementations**

The convenience module was missing the `execute_with_dbt_show_command()` function, even though it existed in the actual implementation.

## The Fix

### Step 1: Updated convenience module
**File:** `dbt-power.nvim/lua/dbt-power/execute.lua`

Added missing function:
```lua
function M.execute_with_dbt_show_command()
  require("dbt-power.dbt.execute").execute_with_dbt_show_command()
end
```

### Step 2: Verified require paths in config
**File:** `lua/plugins/data-tools/dbt.lua`

All keybindings now use the convenience module path:
```lua
<C-CR>     → require("dbt-power.execute").execute_and_show_inline()
<leader>ds → require("dbt-power.execute").execute_with_dbt_show_command()
v<C-CR>    → require("dbt-power.execute").execute_selection()
<leader>dv → require("dbt-power.preview").show_compiled_sql()
<leader>dC → require("dbt-power.ui.inline_results").clear_all()
```

## What Changed

```diff
# dbt-power.nvim/lua/dbt-power/execute.lua
function M.execute_and_show_inline()
  require("dbt-power.dbt.execute").execute_and_show_inline()
end

+function M.execute_with_dbt_show_command()
+  require("dbt-power.dbt.execute").execute_with_dbt_show_command()
+end

function M.execute_selection()
  require("dbt-power.dbt.execute").execute_selection()
end
```

## Testing

After the fix, all keybindings should work:

```vim
" In a dbt model file
<leader>dc    # Compile (dbtpal)
<leader>dr    # Run model (dbtpal)
<C-CR>        # Execute model (Power User approach)
<leader>ds    # Execute model (dbt show approach)
v<C-CR>       # Execute visual selection
<leader>dv    # Preview compiled SQL
<leader>dC    # Clear results
```

## Git Commits

The fix is in commit: `ddc439f` in dbt-power.nvim

```bash
ddc439f fix: Add missing execute_with_dbt_show_command to convenience module
```

## If the Error Persists

1. **Restart Neovim** completely:
   ```bash
   # Close all Neovim instances
   pkill nvim
   nvim  # Open fresh
   ```

2. **Clear Neovim cache**:
   ```bash
   rm -rf ~/.cache/nvim
   nvim  # Open fresh
   ```

3. **Reinstall plugins**:
   ```vim
   :Lazy sync
   :Lazy reload dbt-power
   ```

4. **Check plugin status**:
   ```vim
   :Lazy show dbt-power
   " Should show "dbt-power" plugin loaded
   ```

## Why This Happened

The dbt-power.nvim plugin uses a convenience wrapper pattern:
- Convenience module (`execute.lua`) → Actual module (`dbt/execute.lua`)

This was incomplete - only 2 of 3 functions were wrapped, causing the nil error when calling the third.

## Summary

✅ Added missing `execute_with_dbt_show_command()` wrapper function
✅ Verified all require paths are correct
✅ dbt show execution (`<leader>ds`) now works
✅ No more E5108 errors

All execution methods now available:
- `<C-CR>` for Power User approach
- `<leader>ds` for dbt show approach
- `v<C-CR>` for visual selection
