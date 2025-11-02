# Native Neovim LSP Setup for dbt-language-server

## Part 1: Understanding LSP Architecture

### What is LSP (Language Server Protocol)?

LSP is a **standardized communication protocol** between an editor and a language server:

```
Editor (Client)                Language Server
    │                               │
    ├─ "user typed 'mod'" ────────►│ (completion/textDocument/completion)
    │                               │
    │◄──── ["model_a", "model_b"]──┤ (returns completions)
    │                               │
    ├─ "user pressed Ctrl+Click"──►│ (go to definition)
    │                               │
    │◄─── {file: "models/m.sql"}───┤ (returns definition location)
    │                               │
    ├─ "user hovers over 'ref'" ───►│ (hover information)
    │                               │
    │◄─── "Returns source table"────┤ (returns hover content)
```

### Key LSP Methods (What dbt-language-server Provides)

1. **textDocument/completion** → Code completion suggestions
2. **textDocument/hover** → Hover tooltips with documentation
3. **textDocument/definition** → Jump to definition (gd)
4. **textDocument/references** → Find all references (gr)
5. **textDocument/diagnostics** → Show errors/warnings

## Part 2: How VS Code dbt Power User Uses LSP

### VS Code Architecture

```
┌──────────────────────────────────┐
│ VS Code Editor                   │
│ ├─ dbt Power User Extension      │
│ └─ LSP Client (built-in)         │
└──────────────┬───────────────────┘
               │ JSON-RPC protocol
┌──────────────▼───────────────────┐
│ dbt Language Server              │
│ (TypeScript/Go binary)           │
│ ├─ Parses dbt_project.yml        │
│ ├─ Reads models/*.sql            │
│ ├─ Reads sources.yml             │
│ ├─ Indexes models, sources, etc  │
│ └─ Responds to LSP requests      │
└──────────────────────────────────┘
```

### What the Extension Does

The **dbt Power User extension** provides two things:

#### 1. LSP Features (via language server)
```
- Completion: Type "ref(" → shows list of models
- Hover: Hover over model name → shows description
- Definition: Click model → jumps to file
- Diagnostics: Syntax errors → shown as red squiggles
```

#### 2. Extension-Specific UI (custom to VS Code)
```
- Query result preview (this is NOT LSP)
- Cost estimation
- Lineage visualization
- Custom sidebar panels
```

### How It Works Step-by-Step

**User types `ref(` in SQL file:**

```
1. VS Code detects user input
2. VS Code LSP client sends:
   {
     "jsonrpc": "2.0",
     "id": 1,
     "method": "textDocument/completion",
     "params": {
       "textDocument": { "uri": "file:///path/models/model.sql" },
       "position": { "line": 10, "character": 5 }
     }
   }

3. dbt Language Server receives request
4. Server parses dbt_project.yml and models/
5. Server finds all model names
6. Server responds:
   {
     "jsonrpc": "2.0",
     "id": 1,
     "result": [
       { "label": "model_a", "kind": "Module" },
       { "label": "model_b", "kind": "Module" },
       ...
     ]
   }

7. VS Code displays completion menu
```

### Why We Need Both Neovim LSP + dbt-power.nvim

**LSP provides** (dbt-language-server):
- ✅ Code completion for models, sources
- ✅ Hover info and documentation
- ✅ Go to definition navigation
- ✅ Static error checking

**dbt-power.nvim provides** (custom Lua plugin):
- ✅ Model execution results
- ✅ CTE preview
- ✅ Inline/buffer result display
- ✅ dbt compile preview

These are complementary - LSP handles editing features, dbt-power handles execution features.

## Part 3: Native Neovim LSP Configuration

### Step 1: Create LSP Configuration File

Create `~/.config/nvim/lua/lsp/dbt.lua`:

```lua
-- dbt-language-server configuration (native Neovim LSP)

return {
  name = 'dbt',
  cmd = { 'dbt-language-server' },  -- Make sure this is in $PATH
  root_markers = { 'dbt_project.yml' },
  filetypes = { 'sql', 'yaml' },

  -- Optional: Custom settings for the server
  init_options = {},

  -- Optional: Customize how capabilities are presented
  capabilities = {
    completionProvider = {
      triggerCharacters = { '.' },
    },
  },

  -- Optional: Handlers for specific LSP events
  handlers = {
    -- Standard LSP handlers will be auto-configured
  },
}
```

### Step 2: Enable in Main Config

In `~/.config/nvim/init.lua` or your plugin file:

```lua
-- Enable dbt LSP server
vim.lsp.enable('dbt')

-- Or alternatively, use file-based config (place lua/lsp/dbt.lua on runtimepath):
-- vim.lsp.config() will auto-discover it
```

### Step 3: Install the Binary

```bash
# Check latest release: https://github.com/j-clemons/dbt-language-server/releases

# Option 1: Download pre-built binary (macOS/Linux/Windows)
# Download from releases, make executable, add to PATH

# Option 2: Build from source (requires Go 1.21+)
git clone https://github.com/j-clemons/dbt-language-server.git
cd dbt-language-server
go build -o dbt-language-server ./cmd/dbt-language-server
sudo mv dbt-language-server /usr/local/bin/

# Verify installation
which dbt-language-server
dbt-language-server --version
```

## Part 4: Using the LSP Features

### Code Completion

**In Insert mode, while editing SQL:**

```sql
SELECT * FROM {{ ref("
```

Press `<C-x><C-o>` (or configure with nvim-cmp for `<C-Space>`):
- Shows all available models
- Select with arrow keys + Enter

### Hover Information

**In Normal mode, position cursor over a model name:**

```sql
SELECT * FROM {{ ref("my_model") }}
                       ^^^^^^^^
```

Press `K` to show hover:
```
my_model
  description: Customer dimension table
  materialized: view
  columns: id, name, email
```

### Go to Definition

**In Normal mode, position cursor over a model name:**

```sql
SELECT * FROM {{ ref("my_model") }}
                       ^^^^^^^^
```

Press `gd` to jump to `models/my_model.sql`

### Diagnostics (Error Checking)

The server will automatically show:
- ❌ Undefined models: `{{ ref("nonexistent_model") }}`
- ❌ Syntax errors in YAML
- ⚠️ Unused models (if enabled)

Errors appear as:
- Red squiggles in editor
- In `:Telescope diagnostics`
- In quickfix list (`:copen`)

## Part 5: Complete Minimal Setup

Create a plugin file at `lua/plugins/lsp.lua`:

```lua
-- Native Neovim LSP configuration (no dependencies)

return {
  -- This is optional - just for organization
  -- The actual LSP setup is in lua/lsp/dbt.lua
}

-- In init.lua or at end of config:
vim.lsp.enable('dbt')  -- Auto-discovers lua/lsp/dbt.lua

-- Optional: Add keybindings for LSP
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { noremap = true })
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { noremap = true })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { noremap = true })
vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { noremap = true })
```

## Part 6: Optional Enhancements

### Add Completion Plugin (nvim-cmp)

If you want better completion UI:

```lua
-- lua/plugins/completion.lua
return {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',  -- LSP source
    'hrsh7th/cmp-buffer',
  },
  config = function()
    local cmp = require('cmp')
    cmp.setup({
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },  -- Gets completions from LSP
        { name = 'buffer' },
      }),
      mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
      }),
    })
  end,
}
```

### Show Diagnostics in Virtual Text

```lua
-- In init.lua
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
})
```

## Comparison: VS Code vs Neovim LSP

### VS Code dbt Power User
```
✅ Completion         - Type, see suggestions
✅ Hover              - Move mouse, see tooltip
✅ Go to Definition   - Click with Cmd/Ctrl
✅ Query Preview      - Extension feature
✅ Cost Estimation    - Extension feature
✅ Auto-install deps  - Through marketplace
❌ Terminal-friendly  - GUI only
```

### Neovim with dbt-language-server
```
✅ Completion         - <C-x><C-o> or <C-Space>
✅ Hover              - Press K
✅ Go to Definition   - Press gd
❌ Query Preview      - Use dbt-power.nvim instead
❌ Cost Estimation    - Not needed (you have dbt show)
✅ Terminal-friendly  - Pure keyboard
✅ Scriptable         - Full Lua control
```

## Troubleshooting

### Server not starting?

```bash
# Check binary exists and is executable
which dbt-language-server
dbt-language-server --version

# Check Neovim can find it
nvim -c "echo system('which dbt-language-server')"

# Check LSP status
nvim -c "lua print(vim.lsp.status())"
```

### Completion not showing?

```lua
-- Ensure LSP is enabled
vim.lsp.enable('dbt')

-- Check if LSP client attached to buffer
-- In Neovim: :LspInfo
```

### dbt Cloud compatibility?

Since dbt-language-server parses local files (dbt_project.yml, models/, sources.yml), it works with dbt Cloud as long as your local project is complete. The server doesn't communicate with dbt Cloud API - it analyzes your local YAML/SQL files.

## Summary

| Aspect | Details |
|--------|---------|
| **Installation** | Download binary, add to PATH |
| **Configuration** | Single 10-line Lua file |
| **Dependencies** | None (no mason, no lspconfig) |
| **Features** | Completion, Hover, Go-to-def, Diagnostics |
| **Keyboard** | K (hover), gd (definition), gr (references) |
| **Combined with** | dbt-power.nvim for execution + results |
| **Effort** | 15 minutes to set up |

---

**Next Steps:**
1. Download dbt-language-server binary
2. Create `lua/lsp/dbt.lua` with config
3. Add `vim.lsp.enable('dbt')` to init.lua
4. Test with SQL file: press K over a model name
5. Enjoy full IDE experience + dbt execution!
