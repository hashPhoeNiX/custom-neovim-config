# Molten Cell Borders - Visual Cell Indicators

Add visual Unicode box-drawing borders around detected cells in Molten notebooks.

## Overview

The `molten-cell-borders` module renders decorative borders around Python cells using extmarks, creating a notebook-like visual structure similar to Jupyter notebooks. This complements your existing Molten setup without modifying actual file content.

### Key Features

- **Visual Cell Boundaries**: Unicode box borders around each detected cell
- **Multiple Styles**: Solid, dashed, and double-line border styles
- **Smart Display**: Hides borders in insert mode for distraction-free editing
- **Configurable Width**: Control border width as percentage of window
- **Non-Intrusive**: Uses Neovim's extmarks API (purely visual)
- **Auto-Rendering**: Automatically detects cell changes on buffer save

## Usage

### Quick Start

Borders are **enabled by default** when you open a supported file type:
- `.py` (Python)
- `.ipynb` (Jupyter notebooks)
- `.md` (Markdown with code fences)
- `.qmd` (Quarto documents)

### Keybindings

All keybindings use `<leader>mt` (Molten Toggle/Theme):

| Key | Description |
|-----|-------------|
| `<leader>mtb` | Toggle borders on/off |
| `<leader>mtB` | Refresh borders (force re-render) |
| `<leader>mts` | Change border style (opens selector) |

## Configuration

Configure in `lua/plugins/data-tools/molten.lua`:

```lua
require("config.molten-cell-borders").setup({
  enabled = true,              -- Start with borders enabled
  border_style = "solid",      -- 'solid', 'dashed', or 'double'
  show_in_insert = false,      -- Hide borders while in insert mode
  cell_width_percentage = 90,  -- Border width as % of window
  min_cell_width = 40,         -- Minimum border width
  max_cell_width = 120,        -- Maximum border width
  colors = {
    border = "#6272A4",        -- Border color (hex or hl group)
  },
})
```

### Border Styles

#### Solid (Default)
```
┌──────────────────────────────┐
│ import pandas as pd          │
│ df = pd.read_csv('data.csv')│
└──────────────────────────────┘
```

#### Dashed
```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ import pandas as pd          ┃
┃ df = pd.read_csv('data.csv')┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

#### Double
```
╔══════════════════════════════╗
║ import pandas as pd          ║
║ df = pd.read_csv('data.csv')║
╚══════════════════════════════╝
```

## How It Works

### Cell Detection

Cells are automatically detected using the same algorithm as `molten-commands.lua`:

**Cell boundaries** are marked by:
- Empty lines
- Markdown headings (`#`)
- Code fences (` ``` `)

Example structure:
```python
# Cell 1
import pandas as pd
df = pd.read_csv('data.csv')

# Cell 2 (separated by empty line above)
print(df.head())
```

### Border Rendering

1. **Initialization**: When you enter a buffer, borders are automatically rendered
2. **Auto-Refresh**: Borders update when you save (`:w`)
3. **Insert Mode**: Borders hide while editing to reduce visual clutter
4. **Toggle**: Use `<leader>mtb` to enable/disable without closing the buffer

### Color Customization

Link to existing highlight groups:

```lua
require("config.molten-cell-borders").setup({
  colors = {
    border = "Comment",  -- Links to Comment highlight group
  },
})
```

Or use hex colors:

```lua
colors = {
  border = "#FF79C6",    -- Dracula pink
}
```

## Advanced Usage

### Programmatic Control

You can control borders from Lua:

```lua
local borders = require("config.molten-cell-borders")

-- Toggle borders
borders.toggle_borders()

-- Refresh borders in current buffer
borders.refresh_borders()

-- Change border style
borders.set_border_style("dashed")  -- 'solid', 'dashed', or 'double'
```

### Dynamic Width Adjustment

Borders automatically scale with your window:

```lua
-- Default: 90% of window width
cell_width_percentage = 90

-- Minimum/Maximum constraints
min_cell_width = 40    -- Never narrower than 40 chars
max_cell_width = 120   -- Never wider than 120 chars
```

### Per-Project Configuration

Create a `nvim.lua` or `.nvim.lua` in your project root:

```lua
require("config.molten-cell-borders").setup({
  border_style = "dashed",
  colors = { border = "#50FA7B" },
})
```

## Integration with Molten

The cell borders work seamlessly with your existing Molten setup:

- ✅ Works with all Molten commands
- ✅ Cell detection matches Molten's execution cells
- ✅ Respects your file type settings
- ✅ Doesn't interfere with output rendering
- ✅ Compatible with state persistence

Example workflow:
```
1. <leader>mtb        - Toggle borders on
2. <leader>mts        - Change to 'dashed' style
3. <CR>               - Execute cell (borders hide in insert mode)
4. <S-Down>           - Navigate to next cell
5. <leader>mtB        - Refresh borders after large edit
```

## Performance Considerations

- **Minimal overhead**: Uses Neovim's efficient extmarks API
- **Debounced rendering**: Rendering is delayed 100ms to batch updates
- **On-demand refresh**: Only renders visible cells
- **No file modifications**: Purely visual decorations

## Troubleshooting

### Borders Not Showing

1. Check if borders are enabled: `<leader>mtb`
2. Verify file type is supported (`.py`, `.ipynb`, `.md`, `.qmd`)
3. Force refresh: `<leader>mtB`
4. Check if you're in insert mode (borders hidden by default)

### Borders Look Wrong

1. Try different style: `<leader>mts`
2. Adjust width settings in config
3. Check your font supports Unicode box characters

### Performance Issues

1. Reduce `cell_width_percentage` to render fewer characters
2. Disable borders in large files: `<leader>mtb`
3. Check for conflicting plugins that modify extmarks

## Related Configuration

- **molten-commands.lua**: Cell manipulation and navigation
- **molten-persist.lua**: State persistence across sessions
- **molten.lua**: Main Molten plugin configuration

## Examples

### Markdown Notebook with Borders

File: `analysis.md`

```
# Data Analysis

```python
import pandas as pd
df = pd.read_csv('data.csv')
```

## Exploration

```python
print(df.info())
df.describe()
```

## Visualization

```python
import matplotlib.pyplot as plt
df.plot()
plt.show()
```
```

With borders enabled, each Python code fence is surrounded by a visual border.

### Python Script with Cells

File: `script.py`

```python
# %%
# Data loading
import pandas as pd
df = pd.read_csv('data.csv')

# %%
# Analysis
print(df.describe())

# %%
# Visualization
import matplotlib.pyplot as plt
df.plot()
```

With borders enabled, each section becomes visually distinct.

## Tips

1. **Use markdown headings**: Add structure with `# Section` headers
2. **Empty lines matter**: Separate logical blocks for clear cell boundaries
3. **Combine with Molten**: Borders + execution = Jupyter-like workflow
4. **Customize per project**: Different styles for different projects
5. **Hide for presentations**: Toggle off with `<leader>mtb` when sharing screen

---

**Created**: 2024
**Related**: Molten-nvim, notebook_style.nvim
