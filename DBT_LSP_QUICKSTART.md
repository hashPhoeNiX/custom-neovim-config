# dbt Language Server - Quick Start Guide

## 1. Install dbt-language-server Binary

### Option A: Download Pre-built Binary (Recommended)

```bash
# Check latest version: https://github.com/j-clemons/dbt-language-server/releases

# macOS (Apple Silicon)
wget https://github.com/j-clemons/dbt-language-server/releases/download/v0.3.0/dbt-language-server-darwin-arm64
chmod +x dbt-language-server-darwin-arm64
sudo mv dbt-language-server-darwin-arm64 /usr/local/bin/dbt-language-server

# macOS (Intel)
wget https://github.com/j-clemons/dbt-language-server/releases/download/v0.3.0/dbt-language-server-darwin-amd64
chmod +x dbt-language-server-darwin-amd64
sudo mv dbt-language-server-darwin-amd64 /usr/local/bin/dbt-language-server

# Linux
wget https://github.com/j-clemons/dbt-language-server/releases/download/v0.3.0/dbt-language-server-linux-amd64
chmod +x dbt-language-server-linux-amd64
sudo mv dbt-language-server-linux-amd64 /usr/local/bin/dbt-language-server

# Windows (PowerShell)
Invoke-WebRequest -Uri "https://github.com/j-clemons/dbt-language-server/releases/download/v0.3.0/dbt-language-server-windows-amd64.exe" -OutFile "dbt-language-server.exe"
# Move to PATH
```

### Option B: Build from Source (Requires Go 1.21+)

```bash
git clone https://github.com/j-clemons/dbt-language-server.git
cd dbt-language-server
go build -o dbt-language-server ./cmd/dbt-language-server
sudo mv dbt-language-server /usr/local/bin/
```

### Verify Installation

```bash
# Check it's in PATH
which dbt-language-server

# Test it works
dbt-language-server --version
```

## 2. Configuration Already Done!

Your Neovim is already configured:

✅ `lua/lsp/dbt.lua` - LSP configuration
✅ `lua/config/lsp.lua` - LSP enabled
✅ `lua/config/lsp-keymaps.lua` - Keybindings set

## 3. Restart Neovim

```bash
# Kill existing Neovim processes
pkill nvim

# Start fresh
nvim
```

## 4. Test It Works

Open a dbt SQL model file:

```bash
nvim data-dpac-dbt-models/models/staging/clean/reliance_ml_ng_core/stg_reliance_ml_ng_core__active_status.sql
```

### Test Completion

In insert mode, type:

```sql
SELECT * FROM {{ ref("
```

Then press `<C-x><C-o>` (or if you have nvim-cmp, `<C-Space>`):
- Should show list of available models
- Type to filter: "stg_", see suggestions
- Press Enter to select

### Test Hover

In normal mode, position cursor over a model name:

```sql
SELECT * FROM {{ ref("stg_customers") }}
                       ^^^^^^^^^^^^^
```

Press `K` to show hover information:
- Model description
- Materialization type
- Columns

### Test Go to Definition

Same position as above, press `gd` to jump to the model file.

### Test Find References

Position cursor over model name, press `gr` to find all places it's referenced.

## 5. Available Keybindings

| Key | Action | Details |
|-----|--------|---------|
| `K` | Hover | Show model/column documentation |
| `gd` | Go to Definition | Jump to model file |
| `gr` | Find References | Show where model is used |
| `gK` | Signature Help | Show function signatures |
| `<leader>cd` | Show Diagnostics | Display error details |
| `<leader>ud` | Toggle Diagnostics | Enable/disable error showing |

## 6. Features You Now Have

### Code Completion

Type `{{ ref("` and see all available models:
```
- stg_customers
- stg_orders
- stg_products
...
```

Type `{{ source("` and see all sources:
```
- raw_customers
- raw_orders
...
```

### Hover Information

Hover over or press K on:
- Model names → shows description, columns
- Source names → shows database, schema, table
- Macro names → shows macro documentation

### Static Error Detection

Red squiggles appear for:
- ❌ Undefined models: `{{ ref("nonexistent_model") }}`
- ❌ Undefined sources: `{{ source("fake_db", "table") }}`
- ❌ Syntax errors in YAML

## 7. Integration with dbt-power.nvim

You now have **both**:

| Feature | Tool |
|---------|------|
| Code Completion | dbt-language-server |
| Hover Info | dbt-language-server |
| Go to Definition | dbt-language-server |
| Find References | dbt-language-server |
| Execute Models | dbt-power.nvim (`<leader>dr`) |
| Inline Results | dbt-power.nvim (`<leader>ds`) |
| Buffer Results | dbt-power.nvim (`<leader>dS`) |
| CTE Preview | dbt-power.nvim (`<leader>dq`) |

Perfect combination! LSP for editing, dbt-power for execution.

## 8. Troubleshooting

### LSP not starting?

```lua
-- In Neovim, check LSP status:
:LspInfo
```

Expected output:
```
Language server dbt (id: 1) started by default handlers.
  cmd: dbt-language-server
  filetypes: sql, yaml
  root_dir: /path/to/dbt_project.yml
```

### "dbt-language-server not found"

```bash
# Make sure it's in PATH
which dbt-language-server

# If not found:
# 1. Download binary again
# 2. Make it executable: chmod +x dbt-language-server
# 3. Move to /usr/local/bin or add directory to PATH
```

### Completion not showing?

```lua
-- Try manual trigger in insert mode:
<C-x><C-o>   -- LSP completion
-- or
<C-Space>    -- if using nvim-cmp
```

### Hover showing wrong information?

Make sure you're in a dbt project with `dbt_project.yml` in the root:

```bash
cd /path/to/dbt/project
ls dbt_project.yml  # Should exist
nvim models/staging/model.sql
```

## 9. Next Steps

Now you have a complete IDE setup:

✅ **Editing**: Completion, Hover, Navigation (LSP)
✅ **Execution**: Run models, preview results (dbt-power)
✅ **Debugging**: CTE preview, compiled SQL view

Enjoy your enhanced dbt development experience!

---

**Questions?**
- Check `NATIVE_LSP_DBT_SETUP.md` for detailed architecture explanation
- See keybindings in `lua/config/lsp-keymaps.lua`
- dbt-language-server docs: https://github.com/j-clemons/dbt-language-server
