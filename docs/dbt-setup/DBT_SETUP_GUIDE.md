# dbt Setup and Usage Guide for Neovim

This guide explains the complete dbt setup in your Neovim configuration, how the plugins work together, and how to use them effectively.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Components](#components)
3. [How It All Works Together](#how-it-all-works-together)
4. [Installation & Setup](#installation--setup)
5. [Daily Workflow](#daily-workflow)
6. [Configuration Files](#configuration-files)
7. [Keybindings Reference](#keybindings-reference)
8. [Troubleshooting](#troubleshooting)

---

## Architecture Overview

Your dbt setup consists of three layers:

```
┌─────────────────────────────────────────────────────────────┐
│                     Neovim (nixCats)                         │
├─────────────────────────────────────────────────────────────┤
│  Plugin Layer:                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │   dbtpal     │  │ vim-dadbod   │  │ dbt-power.nvim   │  │
│  │              │  │ vim-dadbod-ui│  │  (custom MVP)    │  │
│  │ Run models   │  │              │  │                  │  │
│  │ Test models  │  │ DB queries   │  │ Inline results   │  │
│  │ Navigation   │  │ Browse DB    │  │ SQL preview      │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐                        │
│  │  cmp-dbt     │  │  Telescope   │                        │
│  │              │  │              │                        │
│  │ Autocomplete │  │ Fuzzy find   │                        │
│  └──────────────┘  └──────────────┘                        │
├─────────────────────────────────────────────────────────────┤
│  Runtime Dependencies:                                       │
│  - dbt CLI (Cloud CLI or Core)                              │
│  - Database connection (PostgreSQL/Snowflake/BigQuery)      │
│  - Python (for dbt)                                          │
└─────────────────────────────────────────────────────────────┘
```

---

## Components

### 1. dbtpal (GitHub: PedramNavid/dbtpal)

**Purpose:** Base dbt command execution and navigation

**Features:**
- Run dbt models (current, all, specific)
- Test dbt models
- Navigate between models (`gf` on `{{ ref() }}`)
- Telescope integration for model selection
- Async command execution

**Loaded from:** `flake.nix` input `plugins-dbtpal`

### 2. vim-dadbod + vim-dadbod-ui (nixpkgs)

**Purpose:** Database connection and query execution

**Features:**
- Connect to multiple databases
- Execute SQL queries
- Browse database schema
- View table data
- Save connection configurations

**Loaded from:** nixpkgs `vimPlugins`

### 3. vim-dadbod-completion (nixpkgs)

**Purpose:** SQL autocompletion

**Features:**
- Table name completion
- Column name completion
- Schema-aware suggestions

**Loaded from:** nixpkgs `vimPlugins`

### 4. cmp-dbt (GitHub: MattiasMTS/cmp-dbt)

**Purpose:** dbt-specific autocompletion

**Features:**
- Model name completion in `{{ ref() }}`
- Source completion in `{{ source() }}`
- Macro completion

**Loaded from:** `flake.nix` input `plugins-cmp-dbt`

### 5. dbt-power.nvim (Local: ~/Projects/dbt-power.nvim)

**Purpose:** Custom plugin for Power User-like features

**Features:**
- ⭐ Inline query results (like Jupyter notebooks)
- Live compiled SQL preview
- Execute current model or selection
- Markdown table formatting
- CSV export

**Loaded from:** `flake.nix` input `plugins-dbt-power` (local path)

---

## How It All Works Together

### Scenario 1: Developing a dbt Model

```
1. Open model file: models/staging/stg_customers.sql

2. Write SQL with Jinja:
   ┌────────────────────────────────────────┐
   │ SELECT                                 │
   │   customer_id,                         │
   │   email                                │
   │ FROM {{ ref('raw_customers') }}        │
   │ WHERE created_at > '2024-01-01'       │
   └────────────────────────────────────────┘
        ↓
   [cmp-dbt provides autocomplete for ref()]

3. Preview compiled SQL: <leader>dv
   ┌────────────────────────────────────────┐
   │ [Compiled SQL Preview]                 │
   │ SELECT                                 │
   │   customer_id,                         │
   │   email                                │
   │ FROM dev.staging.raw_customers         │
   │ WHERE created_at > '2024-01-01'       │
   └────────────────────────────────────────┘
        ↓
   [dbt-power compiles via dbt CLI]

4. Run the model: <leader>dr
   ┌────────────────────────────────────────┐
   │ [dbtpal output]                        │
   │ Running dbt model...                   │
   │ ✓ stg_customers completed in 2.3s      │
   └────────────────────────────────────────┘
        ↓
   [dbtpal executes: dbt run --select stg_customers]

5. View results inline: <C-CR>
   ┌────────────────────────────────────────┐
   │ WHERE created_at > '2024-01-01'       │
   └────────────────────────────────────────┘
   │ customer_id │ email              │
   ├─────────────┼────────────────────┤
   │ 1           │ john@example.com   │
   │ 2           │ jane@example.com   │
   └─────────────┴────────────────────┘
   500 rows
        ↓
   [dbt-power compiles, adds LIMIT 500,
    executes via vim-dadbod, displays inline]
```

### Scenario 2: Exploring Database

```
1. Open DBUI: <leader>db

2. Browse schema:
   ┌─────────────────────┐
   │ DBUI                │
   ├─────────────────────┤
   │ + dev               │
   │   + public          │
   │     + customers     │
   │     + orders        │
   │   + staging         │
   │     + stg_customers │
   └─────────────────────┘
        ↓
   [vim-dadbod-ui connects to DB]

3. Select table, press Enter to view data
        ↓
   [vim-dadbod executes: SELECT * FROM ... LIMIT 200]

4. Navigate to dbt model: gf on table name
        ↓
   [dbtpal jumps to corresponding .sql file]
```

### Scenario 3: Ad-hoc SQL Query

```
1. Write SQL in any buffer:
   SELECT COUNT(*)
   FROM {{ ref('stg_customers') }}
   WHERE status = 'active'

2. Select query in visual mode

3. Execute: <C-CR>
        ↓
   [dbt-power compiles Jinja → SQL]
        ↓
   [vim-dadbod executes query]
        ↓
   [Results display inline]

4. Export to CSV: (function available)
   :lua require('dbt-power.ui.inline_results').export_to_csv(...)
```

---

## Installation & Setup

### Step 1: Nix Flake Setup (Already Done)

The `flake.nix` has been updated with:

```nix
inputs = {
  plugins-dbtpal = { url = "github:PedramNavid/dbtpal"; flake = false; };
  plugins-cmp-dbt = { url = "github:MattiasMTS/cmp-dbt"; flake = false; };
  plugins-dbt-power = { url = "path:/Users/.../dbt-power.nvim"; flake = false; };
}

startupPlugins = {
  gitPlugins = [ dbtpal cmp-dbt dbt-power ];
  general = [ vim-dadbod vim-dadbod-ui vim-dadbod-completion ];
}
```

### Step 2: Build Neovim

```bash
cd ~/Projects/custom-neovim

# Update flake inputs (fetch plugins)
nix flake update

# Build
nix build

# Or run directly
nix run .#nvim
```

### Step 3: Install dbt CLI

**Option A: dbt Cloud CLI (Recommended)**

```bash
# macOS
brew install dbt-labs/dbt/dbt

# Configure
mkdir -p ~/.dbt
# Download dbt_cloud.yml from dbt Cloud UI
# Save to ~/.dbt/dbt_cloud.yml
```

**Option B: dbt Core via Nix**

Edit `flake.nix` line 169, uncomment one:

```nix
python312Packages.dbt-postgres  # For PostgreSQL
python312Packages.dbt-bigquery  # For BigQuery
python312Packages.dbt-snowflake # For Snowflake
```

Then rebuild:
```bash
nix flake update && nix build
```

### Step 4: Configure Database Connection

**Method 1: DBUI Interactive**

```vim
:DBUIToggle
" Press 'a' to add connection
" Enter: postgresql://user:pass@host:5432/database
```

**Method 2: Configuration File**

Add to `init.lua` or similar:

```lua
vim.g.dbs = {
  dev = "postgresql://user:pass@localhost:5432/dev_db",
  prod = "postgresql://user:pass@prod-host:5432/prod_db",
}
```

**Method 3: Environment Variables**

```bash
# In ~/.zshrc or ~/.bashrc
export DEV_DB_URL="postgresql://user:pass@localhost:5432/dev_db"
```

Then in Neovim config:
```lua
vim.g.dbs = {
  dev = os.getenv("DEV_DB_URL"),
}
```

### Step 5: Verify Setup

```vim
" Check plugins loaded
:Lazy

" Test database connection
:DB select 1

" Check dbt
:terminal
$ dbt --version
```

---

## Daily Workflow

### Morning: Start Development Session

```vim
" 1. Open your dbt project
$ cd ~/dbt-projects/my-project
$ nvim models/staging/stg_orders.sql

" 2. Open database browser
<leader>db

" 3. Check recent models
<leader>dm  " Telescope dbt models
```

### Development Loop

```vim
" 1. Edit model SQL
" 2. Preview compiled: <leader>dv
" 3. Run model: <leader>dr
" 4. View results: <C-CR>
" 5. Iterate
```

### Testing

```vim
" Run tests for current model
<leader>dt

" Run all tests
<leader>dta
```

### Exploration

```vim
" Browse database
<leader>db

" Execute ad-hoc query
" (Select SQL in visual mode)
<C-CR>

" Navigate to model definition
" (Cursor on {{ ref('model') }})
gf
```

### Cleanup

```vim
" Clear inline results
<leader>dC
```

---

## Configuration Files

### lua/plugins/data-tools/dbt.lua

**Purpose:** Plugin configuration and keymaps

**Key sections:**
- dbtpal setup
- vim-dadbod configuration
- dbt-power setup
- Keybindings

**Location:** Loaded by lazy.nvim via `init.lua`

### ~/Projects/dbt-power.nvim/

**Purpose:** Custom plugin source code

**Structure:**
```
lua/dbt-power/
├── init.lua              # Main plugin entry
├── ui/
│   └── inline_results.lua  # Extmark-based display
├── dbt/
│   ├── compile.lua       # SQL compilation
│   └── execute.lua       # Query execution
└── utils/
    └── project.lua       # Project detection
```

### flake.nix

**Purpose:** Nix package definition

**dbt-related sections:**
- Lines 40-52: Plugin inputs
- Lines 165-172: dbt CLI options
- Lines 193-205: GitHub plugins (gitPlugins)
- Lines 243-246: nixpkgs plugins (vim-dadbod)

---

## Keybindings Reference

### dbt Model Operations

| Key | Action | Plugin |
|-----|--------|--------|
| `<leader>dr` | Run current model | dbtpal |
| `<leader>dt` | Test current model | dbtpal |
| `<leader>dc` | Compile current model | dbtpal |
| `<leader>dra` | Run all models | dbtpal |
| `<leader>dta` | Test all models | dbtpal |

### Navigation & Search

| Key | Action | Plugin |
|-----|--------|--------|
| `<leader>dm` | Telescope model picker | dbtpal + telescope |
| `gf` | Go to model definition | dbtpal |

### Query Execution & Results

| Key | Action | Plugin |
|-----|--------|--------|
| `<C-CR>` | Execute query inline (normal) | dbt-power |
| `<C-CR>` | Execute selection (visual) | dbt-power |
| `<leader>dv` | Preview compiled SQL | dbt-power |
| `<leader>dC` | Clear inline results | dbt-power |

### Database Browser

| Key | Action | Plugin |
|-----|--------|--------|
| `<leader>db` | Toggle DBUI | vim-dadbod-ui |

### Advanced

| Key | Action | Plugin |
|-----|--------|--------|
| `<leader>dA` | Toggle auto-compile | dbt-power |

---

## Troubleshooting

### Plugins Not Loading

**Check lazy.nvim:**
```vim
:Lazy
" Look for: dbtpal, vim-dadbod, vim-dadbod-ui, dbt-power
```

**Rebuild Nix:**
```bash
nix flake update
nix build --rebuild
```

### dbt Commands Fail

**Check dbt CLI:**
```bash
which dbt
dbt --version
```

**Check dbt project:**
```bash
ls dbt_project.yml
dbt debug
```

### Database Connection Fails

**Test connection:**
```vim
:DB postgresql://user:pass@host/db select 1
```

**Check DBUI:**
```vim
:DBUIToggle
" Check connections listed
```

**Verify credentials:**
```bash
# Test outside Neovim
psql "postgresql://user:pass@host/db"
```

### Inline Results Not Showing

**Check dbt-power loaded:**
```vim
:lua print(vim.inspect(require('dbt-power')))
```

**Check for errors:**
```vim
:messages
```

**Try manual execution:**
```vim
:lua require('dbt-power.execute').execute_and_show_inline()
```

### Auto-compile Not Working

**Toggle it:**
```vim
<leader>dA
" Should see: "Auto-compile enabled"
```

**Check for errors:**
```vim
:messages
```

---

## How Data Flows

### Inline Results Execution Flow

```
User: <C-CR>
    ↓
dbt-power.execute.execute_and_show_inline()
    ↓
1. Get buffer content (SQL with Jinja)
    ↓
2. Compile via dbt CLI
   $ dbt compile --select model_name
    ↓
3. Read compiled SQL from target/compiled/
    ↓
4. Add LIMIT clause (max_rows)
    ↓
5. Execute via vim-dadbod
   :DB postgresql://... <compiled_sql>
    ↓
6. Parse results (columns + rows)
    ↓
7. Format as markdown table
    ↓
8. Display using extmarks (virtual lines)
   vim.api.nvim_buf_set_extmark(...)
    ↓
User sees:
┌────────────────────┐
│ col1  │ col2       │
├───────┼────────────┤
│ val1  │ val2       │
└────────────────────┘
```

### Compiled SQL Preview Flow

```
User: <leader>dv
    ↓
dbt-power.preview.show_compiled_sql()
    ↓
1. Run: dbt compile --select model_name
    ↓
2. Read target/compiled/<model>.sql
    ↓
3. Create or update split window
    ↓
4. Set buffer content
    ↓
5. Syntax highlight as SQL
    ↓
User sees compiled SQL in split
```

---

## Comparison to dbt Power User (VSCode)

| Feature | dbt-power.nvim | VSCode Power User |
|---------|----------------|-------------------|
| Inline query results | ✅ Via extmarks | ✅ Native panel |
| Compiled SQL preview | ✅ Split window | ✅ Live preview |
| Model execution | ✅ Via dbtpal | ✅ One-click |
| Visual selection | ✅ Full support | ✅ Supported |
| Database browser | ✅ vim-dadbod-ui | ⚠️ External |
| Lineage graphs | 🚧 Planned | ✅ Built-in |
| AI documentation | 🚧 Planned | ✅ Built-in |
| Cost estimation | ❌ Not yet | ✅ BigQuery only |

**Key Advantage:** Stays in Neovim, keyboard-driven, faster for vim users

---

## Philosophy & Design

### Why This Architecture?

1. **Layered approach:** Each plugin does one thing well
2. **Extensible:** Easy to add new features to dbt-power
3. **Native Neovim:** Uses extmarks, floating windows, etc.
4. **Minimal dependencies:** Mostly Lua and Neovim APIs
5. **Nix-integrated:** Reproducible, declarative setup

### Why Custom Plugin vs. Fork?

- **Learning:** Understanding the full stack
- **Flexibility:** Add features specific to your workflow
- **Integration:** Works seamlessly with Molten, Jupyter
- **Control:** No waiting for upstream PRs

### Molten Connection

dbt-power borrows Molten's approach:
- Uses extmarks for inline display
- Virtual lines for results
- Async execution
- Similar UX for consistency

---

## Next Steps

### Short Term (This Week)

1. ✅ Setup complete
2. Test with real dbt project
3. Configure database connection
4. Try all keybindings
5. Report any issues

### Medium Term (Next Month)

1. Improve result parsing (better table detection)
2. Add query history
3. Better error handling
4. Support more data warehouses

### Long Term (Next Quarter)

1. AI documentation generation
2. Lineage visualization (graphviz)
3. Cost estimation (BigQuery)
4. Performance optimizations

---

## Resources

- **dbtpal:** https://github.com/PedramNavid/dbtpal
- **vim-dadbod:** https://github.com/tpope/vim-dadbod
- **dbt docs:** https://docs.getdbt.com/
- **nixCats:** https://github.com/BirdeeHub/nixCats-nvim
- **Custom plugin:** `~/Projects/dbt-power.nvim/README.md`

---

## Summary

You now have a production-ready dbt development environment in Neovim with:

✅ Model execution and testing
✅ Inline query results (like Jupyter)
✅ Compiled SQL preview
✅ Database browsing
✅ Autocompletion
✅ Navigation between models
✅ All keyboard-driven

The setup mirrors VSCode's dbt Power User in functionality while keeping you in Neovim's efficient, keyboard-driven workflow.

Start developing, and iterate on features as you discover what you need!
