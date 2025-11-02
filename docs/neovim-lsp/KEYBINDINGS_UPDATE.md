# dbt Keybindings Update

## Issue Fixed

Overlapping keybindings caused delays:
- `<leader>dr` and `<leader>dra` conflicted
- `<leader>dt` and `<leader>dta` conflicted

## New Keybindings (Non-overlapping)

### Model Operations

| Key | Action | Old Key |
|-----|--------|---------|
| `<leader>dr` | Run current model | (same) |
| `<leader>dR` | Run all models | `<leader>dra` |
| `<leader>dt` | Test current model | (same) |
| `<leader>dT` | Test all models | `<leader>dta` |
| `<leader>dc` | Compile current model | (same) |

### Navigation & Tools

| Key | Action |
|-----|--------|
| `<leader>dm` | Find model (Telescope) |
| `<leader>dv` | Preview compiled SQL |
| `<leader>db` | Toggle Database UI |

### Results Management

| Key | Action |
|-----|--------|
| `<C-CR>` | Execute query inline |
| `<leader>dC` | Clear query results |
| `<leader>dA` | Toggle auto-compile |

## Pattern

- **Lowercase** = current/single item
  - `<leader>dr` = run current
  - `<leader>dt` = test current

- **Uppercase** = all/multiple items
  - `<leader>dR` = run all
  - `<leader>dT` = test all

## Reload to Apply Changes

```bash
cd ~/Projects/custom-neovim
direnv reload
```

Or in Neovim:
```vim
:source $MYVIMRC
:Lazy reload dbtpal
```

## Quick Reference Card

```
dbt Commands (leader = space)
─────────────────────────────
<space>dr  →  Run current model
<space>dR  →  Run ALL models
<space>dt  →  Test current
<space>dT  →  Test ALL
<space>dc  →  Compile model
<space>dm  →  Find model
<space>dv  →  Preview SQL
<space>db  →  Database UI
<C-CR>     →  Execute inline
```

## Memory Aid

Think of it as:
- **r**un / **R**un all
- **t**est / **T**est all
- **c**ompile
- **m**odels (find)
- **v**iew (preview)
- **b**rowser (database)
