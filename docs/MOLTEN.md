# Molten-nvim Configuration Documentation

Complete guide to the Jupyter-like notebook experience in Neovim using Molten-nvim.

---

## Table of Contents

1. [Overview](#overview)
2. [File Structure](#file-structure)
3. [Features](#features)
4. [Keybindings Reference](#keybindings-reference)
5. [State Persistence](#state-persistence)
6. [Configuration Options](#configuration-options)
7. [Usage Examples](#usage-examples)
8. [Technical Details](#technical-details)

---

## Overview

This configuration provides a complete Jupyter-like notebook experience in Neovim using [Molten-nvim](https://github.com/benlubas/molten-nvim). Key capabilities include:

- **Interactive Code Execution**: Run Python, Jupyter notebooks, and other kernel languages directly in Neovim
- **Persistent State**: Cell outputs and execution state are automatically saved and restored
- **Smart Cell Detection**: Automatically detects cell boundaries based on code structure
- **Enhanced Commands**: Full suite of Jupyter-like commands (run all, restart kernel, etc.)
- **Visual Feedback**: Inline output display with virtual text and output windows

### Supported File Types

The configuration is active for:
- `.ipynb` - Jupyter notebooks
- `.py` - Python files
- `.md` - Markdown files (with code fences)
- `.qmd` - Quarto documents

---

## File Structure

```
custom-neovim/
├── lua/
│   ├── plugins/
│   │   └── data-tools/
│   │       └── molten.lua           # Main Molten configuration
│   └── config/
│       ├── molten-persist.lua       # State persistence system
│       └── molten-commands.lua      # Enhanced Jupyter commands
└── .molten/                         # Saved cell outputs (auto-generated)
    └── *.ipynb.molten.json          # State files per notebook
```

### File Descriptions

- **`molten.lua`**: Core plugin setup, keybindings, and autocmds
- **`molten-persist.lua`**: Handles saving/loading cell outputs across sessions
- **`molten-commands.lua`**: Extended functionality (run all, cell manipulation, etc.)
- **`.molten/`**: Directory where cell execution state is persisted as JSON

---

## Features

### 1. Smart Cell Detection

Cells are automatically detected based on code structure:
- **Boundary markers**: Empty lines, markdown headings (`#`), code fences (` ``` `)
- **Multi-line support**: Functions, classes, and code blocks are treated as single cells
- **Context-aware**: Understands when you're inside vs. outside a cell

### 2. Automatic State Persistence

Cell outputs are automatically saved:
- **On save** (`:w` or `BufWritePost`)
- **On exit** (`VimLeavePre`)
- **Per-notebook**: Each notebook has its own state file in `.molten/`

State is automatically restored when you reopen a notebook.

### 3. Enhanced Cell Execution

Press `<CR>` (Enter) to execute:
- **Existing cells**: Re-evaluates and moves to next cell
- **New code blocks**: Detects boundaries and evaluates entire block
- **Single lines**: Falls back to line-by-line execution

### 4. File-Type Specific Keybindings

The special Enter key behavior and visual mode execution are only active in:
- Python files (`.py`)
- Jupyter notebooks (`.ipynb`)
- Markdown files (`.md`)
- Quarto documents (`.qmd`)

Other file types retain normal Enter key behavior.

---

## Keybindings Reference

### Basic Execution

| Key | Mode | Description |
|-----|------|-------------|
| `<CR>` | Normal | Execute current cell and move to next |
| `<CR>` | Visual | Execute visual selection |
| `<S-Down>` | Normal | Go to next cell |
| `<S-Up>` | Normal | Go to previous cell |

### Run Commands (`<leader>mr`)

| Key | Description |
|-----|-------------|
| `<leader>mra` | Run all cells in notebook |
| `<leader>mrA` | Run all cells above (including current) |
| `<leader>mrb` | Run all cells below (including current) |

### Kernel Management (`<leader>mk`)

| Key | Description |
|-----|-------------|
| `<leader>mi` | Initialize kernel (prompts for kernel selection) |
| `<leader>mdi` | Deinitialize/stop kernel |
| `<leader>mkr` | Restart kernel (prompts: keep/clear outputs) |
| `<leader>mkR` | Restart kernel and run all cells |
| `<leader>mki` | Interrupt kernel (stop execution) |
| `<leader>mks` | Show kernel status |

### Output Management (`<leader>mo`)

| Key | Description |
|-----|-------------|
| `<leader>mo` | Enter output window |
| `<leader>mh` | Hide output window |
| `<leader>ms` | Show output window |
| `<leader>moc` | Clear output of current cell |
| `<leader>moC` | Clear all outputs in notebook |

### Cell Manipulation (`<leader>mc`)

| Key | Description |
|-----|-------------|
| `<leader>mnc` | New code cell (creates ` ```python ` fence) |
| `<leader>mcs` | Select current cell (visual mode) |
| `<leader>mcy` | Yank/copy current cell |
| `<leader>mcp` | Paste cell below current cell |
| `<leader>mcx` | Split cell at cursor position |
| `<leader>mcm` | Merge current cell with cell below |
| `<leader>mcK` | Move cell up |
| `<leader>mcJ` | Move cell down |

### Navigation (`<leader>mn`)

| Key | Description |
|-----|-------------|
| `<leader>mng` | Go to first cell in notebook |
| `<leader>mnG` | Go to last cell in notebook |

### Additional Commands

| Key | Description |
|-----|-------------|
| `<leader>ml` | Evaluate single line |
| `<leader>mv` | Evaluate visual selection |
| `<localleader>e` | Evaluate operator |
| `<localleader>mr` | Re-evaluate current cell |
| `<localleader>md` | Delete current cell |
| `<localleader>mx` | Open output in browser (for HTML) |

### Vim Commands

| Command | Description |
|---------|-------------|
| `:NewNotebook <name>` | Create new notebook with proper Jupyter metadata |
| `:MoltenInit [kernel]` | Initialize kernel manually |
| `:MoltenDeinit` | Stop kernel |
| `:MoltenAvailableKernels` | List available Jupyter kernels |

---

## State Persistence

### How It Works

The state persistence system saves cell execution outputs to `.molten/` directory:

```
project/
├── notebook.ipynb
└── .molten/
    └── notebook.ipynb.molten.json
```

Each state file contains:
- Kernel name
- Cell positions (line numbers)
- Execution counts
- Cell outputs (text, data, metadata)
- Success/failure status

### When State is Saved

1. **On buffer write** (`:w`)
2. **On Vim exit** (when leaving a notebook buffer)

### When State is Loaded

1. **On notebook open** - Checks for saved state first
2. **Fallback** - Imports outputs from `.ipynb` file if no saved state

### Manual State Management

You can also manually save/load state:

```vim
:MoltenSave /path/to/state.json
:MoltenLoad /path/to/state.json
```

### .gitignore Recommendation

Add to your `.gitignore`:

```gitignore
# Molten state files
.molten/
```

This keeps local execution outputs out of version control.

---

## Configuration Options

### Global Molten Settings

Located in `lua/plugins/data-tools/molten.lua`:

```lua
vim.g.molten_auto_open_output = true           -- Auto-open output window
vim.g.molten_image_provider = "image.nvim"     -- Image rendering backend
vim.g.molten_output_win_max_height = 1000      -- Max output window height
vim.g.molten_output_virt_lines = true          -- Show output as virtual lines
vim.g.molten_virt_text_output = true           -- Show output as virtual text
vim.g.molten_virt_lines_off_by_1 = true        -- Offset virtual lines by 1
vim.g.molten_wrap_output = false               -- Don't wrap long output lines
```

### Per-File-Type Settings

The configuration automatically adjusts settings based on file type:

- **Python files** (`.py`): Virtual lines/text disabled
- **Notebooks/Markdown** (`.ipynb`, `.md`, `.qmd`): Virtual lines/text enabled

This is handled automatically via autocmds.

---

## Usage Examples

### Starting a New Notebook

1. Create a new notebook using the `NewNotebook` command:
   ```vim
   :NewNotebook mynotebook
   ```
   This creates `mynotebook.ipynb` with proper Jupyter metadata.

   **Note**: You can also open an existing notebook with `nvim notebook.ipynb`, but `NewNotebook` is safer for creating new ones as it ensures proper structure.

2. The kernel will initialize automatically, or manually initialize:
   ```
   <leader>mi
   ```
   (Select from available kernels)

3. Write code and press `<CR>` to execute

### Common Workflows

#### Quick Exploration

```
1. Write code
2. Press <CR> to execute
3. Press <CR> again to move to next cell
```

#### Run Entire Notebook

```
<leader>mra    " Run all cells
```

#### Debug Mode: Restart & Run All

```
<leader>mkR    " Restart kernel (clears outputs) and run all
```

#### Clean Up Outputs

```
<leader>moC    " Clear all outputs
:w             " Save (persists the cleared state)
```

### Cell Manipulation Example

```
# Copy a cell and paste it below
<leader>mcy    " Yank current cell
<leader>mcp    " Paste below

# Reorder cells
<leader>mcK    " Move cell up
<leader>mcJ    " Move cell down

# Split a long cell
[Move cursor to split point]
<leader>mcx    " Split at cursor
```

### Working with Markdown Notebooks

In `.md` files, write code in fenced blocks:

````markdown
# My Analysis

```python
import pandas as pd
df = pd.read_csv('data.csv')
```

Press <CR> inside the code fence to execute!

```python
df.head()
```
````

---

## Technical Details

### Cell Boundary Detection Algorithm

The system detects cell boundaries by searching for:

**Start of cell** (searches backward):
- Empty line (`^%s*$`)
- Markdown heading (`^#`)
- Code fence (` ^``` `)

**End of cell** (searches forward):
- Empty line
- Markdown heading
- Code fence

### Kernel Initialization Sequence

1. Check for saved state in `.molten/`
2. If found: Load state with `MoltenLoad` (initializes kernel automatically)
3. If not found:
   - Try to read kernel name from notebook metadata
   - Fall back to active virtual environment name
   - Initialize kernel with `MoltenInit`
   - Import outputs from notebook file

### State Persistence Format

State files are JSON with this structure:

```json
{
  "version": 1,
  "kernel": "python3",
  "content_checksum": "...",
  "cells": [
    {
      "span": {
        "begin": {"lineno": 1, "colno": 0},
        "end": {"lineno": 5, "colno": 0}
      },
      "execution_count": 1,
      "status": 2,
      "success": true,
      "chunks": [
        {
          "data": {"text/plain": "42"},
          "metadata": {}
        }
      ]
    }
  ]
}
```

### Image Support

Image outputs are supported via `image.nvim`:
- PNG, JPEG, SVG images render inline
- Requires image.nvim plugin and compatible terminal

### Why Two State Systems?

The config has both:
- **Molten's native state** (`.molten/` directory) - Cell outputs and execution state
- **Jupyter's `.ipynb` format** - Source code and embedded outputs

Molten's state is preferred because it:
- Loads faster
- Avoids nbformat compatibility issues
- Separates execution state from source code

---

## Troubleshooting

### Outputs Not Persisting

1. Check if `.molten/` directory exists
2. Verify you're saving the buffer (`:w`)
3. Check `:messages` for errors during save

### Kernel Not Starting

1. Check available kernels: `:MoltenAvailableKernels`
2. Manually init: `<leader>mi`
3. Check if kernel is in PATH

### Cell Detection Issues

- Ensure cells are separated by empty lines
- Use markdown headings to separate sections
- Check if you're in a supported file type

### Debug Logging

The configuration includes debug logging. Check `:messages` after opening a notebook to see:
- State file path
- Load success/failure
- Kernel initialization

---

## Tips & Tricks

1. **Use markdown headings**: Structure notebooks with `# Section` headers
2. **Empty lines are your friend**: Separate logical blocks with blank lines
3. **Visual selection**: Select any code block and press `<CR>` to execute
4. **Yank & paste cells**: Copy useful cells across notebooks
5. **Clear outputs before commit**: Use `<leader>moC` to clean up before git commit
6. **Restart for fresh state**: `<leader>mkR` when debugging tricky issues

---

## Related Documentation

- [Molten-nvim GitHub](https://github.com/benlubas/molten-nvim)
- [Jupyter Kernel Documentation](https://docs.jupyter.org/en/latest/projects/kernels.html)
- [Image.nvim](https://github.com/3rd/image.nvim)

---

*Generated for custom-neovim configuration*
