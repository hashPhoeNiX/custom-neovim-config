# Complete dbt Development Setup for Neovim

## Overview

You now have a **complete, production-ready dbt development environment** in Neovim:

```
┌──────────────────────────────────────────┐
│         EDITING FEATURES (LSP)           │
│  Code Completion • Hover • Go-to-Def     │
│         dbt-language-server              │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│      EXECUTION FEATURES (dbt-power)      │
│  Run • Test • Results • CTE Preview      │
│        dbt-power.nvim plugin             │
└──────────────────────────────────────────┘
```

## Installation Checklist

### ✅ Already Done (No Action Needed)

- ✅ dbt-power.nvim configured with execution features
- ✅ Native Neovim LSP configuration files created
- ✅ Keybindings set up
- ✅ CTE preview working with dbt Cloud
- ✅ Inline results improved (narrower columns)

### ⬜ You Need to Do

- ⬜ **Download dbt-language-server binary** (1 command)
- ⬜ **Restart Neovim** (1 command)
- ⬜ **Test it works** (5 minutes)

## One-Time Installation

### macOS

```bash
# Download and install dbt-language-server (3 commands)
wget https://github.com/j-clemons/dbt-language-server/releases/download/v0.3.0/dbt-language-server-darwin-arm64
chmod +x dbt-language-server-darwin-arm64
sudo mv dbt-language-server-darwin-arm64 /usr/local/bin/dbt-language-server

# Verify
dbt-language-server --version

# Restart Neovim
pkill nvim
```

### Linux

```bash
wget https://github.com/j-clemons/dbt-language-server/releases/download/v0.3.0/dbt-language-server-linux-amd64
chmod +x dbt-language-server-linux-amd64
sudo mv dbt-language-server-linux-amd64 /usr/local/bin/dbt-language-server

dbt-language-server --version
pkill nvim
```

That's it! Neovim will auto-detect and use it.

## Feature Reference

### LSP Features (Editing Intelligence)

| Feature | Keymap | Example |
|---------|--------|---------|
| **Completion** | `<C-x><C-o>` | Type `{{ ref("` → see model list |
| **Hover** | `K` | Position on model → see description |
| **Go to Definition** | `gd` | Jump to referenced model file |
| **Find References** | `gr` | Show all places model is used |
| **Show Errors** | `<leader>cd` | Display diagnostics at cursor |
| **Toggle Errors** | `<leader>ud` | Show/hide error underlines |

### dbt-power.nvim Features (Execution)

| Feature | Keymap | What It Does |
|---------|--------|---|
| **Run Model** | `<leader>dr` | Execute model in dbt |
| **Test Model** | `<leader>dt` | Run tests for model |
| **Inline Results** | `<leader>ds` | Show results inline in editor |
| **Buffer Results** | `<leader>dS` | Show results in bottom split |
| **CTE Preview** | `<leader>dq` | Picker to preview individual CTEs |
| **View Compiled SQL** | `<leader>dv` | Show what dbt compiles to |
| **Model Picker** | `<leader>dm` | Telescope picker to find models |
| **Execute Selection** | `Ctrl+Enter` | Power User mode (compile→wrap→execute) |

## Real-World Workflow

### Scenario 1: Quick Model Check

```vim
" You're editing a model and want to see what it produces

:e models/staging/stg_customers.sql

" Check available columns with completion
" Type: SELECT
<C-x><C-o>          " Shows available refs and sources

" Check a referenced model's description
" Position cursor on 'ref("raw_customers")'
K                   " Shows: table schema, columns, etc
gd                  " Jump to that model to review it

" Preview results
<leader>ds          " Inline: see first 10 rows
<leader>dS          " Buffer: see all 500 rows

" Perfect! Commit the changes
```

### Scenario 2: Debugging CTE Logic

```vim
:e models/marts/fact_orders.sql

" Model has multiple CTEs, which is causing issues?
<leader>dq          " Opens CTE picker
" Select: customer_base
" See 7 rows returned - data looks good

" Try next CTE
<leader>dq
" Select: order_details
" See 0 rows - found the bug!

" Jump to definition to fix
gd                  " See the problematic CTE
" Fix the SQL...

" Test again
<leader>dq
" Now it returns correct data
```

### Scenario 3: Building New Model

```vim
" Creating a new model
:e models/staging/stg_new_model.sql

" Type the SQL with auto-complete
WITH customer_base AS (
  SELECT * FROM {{ ref("
                        ^
<C-x><C-o>          " Suggests: raw_customers, stg_customers, etc

" As you type, get completion for columns
SELECT id,
K                   " Hover shows column types
       name,
       {{ ref("  " Completion for refs

" When done, test it
<leader>ds          " See inline results
<leader>dS          " See full result set
<leader>dr          " Actually run it in dbt

" Add to git
git add ...
git commit ...
```

## Architecture Explained (Simple Version)

### What dbt-language-server Does

1. **On Startup**: Reads `dbt_project.yml` in your project root
2. **Indexing**: Scans all files:
   - `models/*.sql` → builds list of all models
   - `sources.yml` → builds list of all sources
   - `macros/` → builds list of all macros
   - Extracts column names from YAML metadata

3. **On Your Request**:
   - You type `{{ ref("` → Returns list of indexed models
   - You press `K` → Returns description for that model
   - You press `gd` → Returns file path and line number

### Why It Doesn't Need dbt Commands

The server **parses YAML/SQL files**, it doesn't:
- ❌ Run `dbt compile`
- ❌ Run `dbt parse`
- ❌ Connect to dbt Cloud
- ❌ Execute anything

This means:
- ✅ Works with dbt Core (local)
- ✅ Works with dbt Cloud (files synced locally)
- ✅ Super fast (no compilation)
- ✅ Works offline

### How It Compares

| Aspect | dbt-language-server | dbt compile |
|--------|---|---|
| Speed | ⚡ Instant | ⏱️ Seconds/minutes |
| Needs dbt installed | ❌ No | ✅ Yes |
| Works with dbt Cloud | ✅ Yes | ✅ Yes |
| Accurate column names | ✅ From YAML | ✅ From parsing |
| Handles Jinja | ⚠️ Basic | ✅ Complete |

## Comparison to VS Code

### dbt Power User in VS Code
```
✅ Code completion
✅ Hover tooltips
✅ Go to definition
✅ Query preview
✅ Easy setup (marketplace)
❌ Heavy (Electron)
❌ Not keyboard-native
```

### Neovim with LSP + dbt-power
```
✅ Code completion (same as VS Code)
✅ Hover tooltips (same as VS Code)
✅ Go to definition (same as VS Code)
✅ Query preview (better than VS Code)
✅ CTE preview (better than VS Code)
✅ Keyboard-native
✅ Fast & lightweight
✅ Works over SSH
❌ More manual setup
```

**You actually have MORE features than VS Code!** 🎉

## Troubleshooting

### LSP not working?

```vim
" Check LSP status
:LspInfo

" Should show:
" Language server dbt (id: 1) started by default handlers.
" cmd: dbt-language-server
" filetypes: sql, yaml
```

### Binary not found?

```bash
# Verify it's in PATH
which dbt-language-server

# If not found:
# 1. Download it again
# 2. Make sure you did: chmod +x
# 3. Make sure you did: sudo mv to /usr/local/bin
# 4. Restart terminal or source ~/.bashrc
```

### Completion not triggering?

```vim
" Try manual trigger:
<C-x><C-o>          " In insert mode

" Or if you installed nvim-cmp:
<C-Space>
```

### Still not working?

```bash
# Test binary manually
dbt-language-server --version
# If it fails, try reinstalling

# Check Neovim sees the binary
nvim -c "echo system('which dbt-language-server')"
```

## Files You Have

| File | Purpose |
|------|---------|
| `lua/lsp/dbt.lua` | LSP configuration |
| `lua/config/lsp.lua` | LSP enabled here |
| `lua/config/lsp-keymaps.lua` | All keybindings |
| `DBT_LSP_QUICKSTART.md` | Installation guide |
| `NATIVE_LSP_DBT_SETUP.md` | Architecture deep-dive |
| `LSP_SETUP_SUMMARY.md` | Comparison to VS Code |
| `COMPLETE_DBT_SETUP.md` | This file |

## Quick Reference: All Keybindings

### Editing (LSP Features)

```vim
K       - Hover: Show model/source/column documentation
gd      - Go to definition: Jump to model file
gr      - References: Find all uses of model
gK      - Signature help: Show function signatures
```

### Execution (dbt-power.nvim)

```vim
<leader>dr      - Run model
<leader>dt      - Test model
<leader>ds      - Inline results
<leader>dS      - Buffer results
<leader>dq      - CTE preview picker
<leader>dv      - View compiled SQL
<leader>dm      - Model picker
<leader>dc      - Compile model
<Ctrl+Enter>    - Power User execute
```

### Diagnostics

```vim
<leader>cd      - Show diagnostics at cursor
<leader>ud      - Toggle all diagnostics
```

## Next: What to Try

1. **Install dbt-language-server** (copy-paste 3 commands)
2. **Restart Neovim** (1 command)
3. **Open a dbt model** file
4. **Try each feature**:
   - Type `{{ ref("` → see completions
   - Press `K` over a model name → see tooltip
   - Press `gd` → jump to definition
   - Press `<leader>ds` → see results

That's it! You now have VS Code's power in Neovim, but faster and better. 🚀

---

**Ready?** Go to `DBT_LSP_QUICKSTART.md` for the 2-minute installation.
