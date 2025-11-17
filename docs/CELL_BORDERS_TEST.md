# Testing Cell Borders Fixes

## What Was Fixed

1. **Markdown code fence detection** - Borders now capture the full code block
2. **Full box rendering** - Complete Unicode borders around all cells in both markdown and Python

## Test Case 1: Markdown Notebook with Long Code Block

### Setup
1. Create a test file: `test_notebook.md`
2. Copy this content:

```markdown
# Data Analysis

## First Section

```python
# Count and display the top 5 most common words in the Zen of Python
import this
from collections import Counter
import re

zen = this.s
words = re.findall(r'\b\w+\b', zen.lower())
counter = Counter(words)
top5 = counter.most_common(5)

print("Top 5 most common words in the Zen of Python:")
for word, count in top5:
    print(f"{word}: {count}")
```

## Second Section

More text here.
```

### What to Check

1. Open the file: `nvim test_notebook.md`
2. Look at the Python code block:
   - ✅ Should see full Unicode border above the opening ` ``` `
   - ✅ Should see full Unicode border below the closing ` ``` `
   - ✅ Top border: `┌────────────────────┐`
   - ✅ Bottom border: `└────────────────────┘`
   - ✅ All 14+ lines of code should be visually contained within borders
3. Check for rendering issues:
   - ❌ No text overlapping
   - ❌ Complete boxes enclosing the code

### Expected Result

```
# Data Analysis

## First Section

┌──────────────────────────────────────────────────────┐
```python
# Count and display the top 5 most common words...
import this
from collections import Counter
import re

zen = this.s
words = re.findall(r'\b\w+\b', zen.lower())
counter = Counter(words)
top5 = counter.most_common(5)

print("Top 5 most common words in the Zen of Python:")
for word, count in top5:
    print(f"{word}: {count}")
```
└──────────────────────────────────────────────────────┘
```

## Test Case 2: Python Script with Cells

### Setup
1. Create a test file: `test_script.py`
2. Copy this content:

```python
# %%
# Data Loading
import pandas as pd
import numpy as np

df = pd.read_csv('data.csv')
print(df.head())

# %%
# Analysis
result = df.groupby('category').sum()
print(result)

# %%
# Visualization
import matplotlib.pyplot as plt
plt.plot(result)
plt.show()
```

### What to Check

1. Open the file: `nvim test_script.py`
2. Look at each cell:
   - ✅ Should see FULL Unicode borders (┌─────┐ style)
   - ✅ Top border appears BEFORE the `# %%` line
   - ✅ Bottom border appears AFTER the last code line
   - ✅ All three cells properly bordered
3. Check border style:
   - Should use full width borders (not simple `┌─ Cell` style)

### Expected Result

```
┌──────────────────────────────┐
│ # %%                          │
│ # Data Loading               │
│ import pandas as pd          │
│ import numpy as np           │
│                              │
│ df = pd.read_csv('data.csv')│
│ print(df.head())            │
└──────────────────────────────┘

┌──────────────────────────────┐
│ # %%                          │
│ # Analysis                    │
│ result = df.groupby('...').  │
│ print(result)                │
└──────────────────────────────┘
```

## Test Case 3: Highlight Overlap Check

### Setup
Ensure you have `render-markdown.nvim` enabled.

### What to Check

1. Open `test_notebook.md`
2. Look at each code block:
   - ✅ The `┌─ Cell` indicator should NOT be cut off
   - ✅ The `└─` indicator should NOT be cut off
   - ✅ Code highlighting should be contained within the block
   - ✅ No "half-shape" borders from clipping
3. Compare with Python file:
   - Full borders in `.py` files
   - Minimal borders in `.md` files

## Test Case 4: Toggle and Refresh

### Test Toggle
1. In any notebook, press: `<leader>mtb`
   - ✅ Borders should disappear
   - ✅ Press again: borders reappear

### Test Refresh
1. In any notebook, press: `<leader>mtB`
   - ✅ Borders should refresh without flickering

### Test Style Change
1. In a `.py` file, press: `<leader>mts`
   - ✅ Opens selector for: solid, dashed, double
   - ✅ Selecting a style updates borders immediately
   - Note: This only affects `.py` files (markdown uses simple style)

## Test Case 5: Insert Mode Behavior

### Setup
1. Open any notebook

### What to Check
1. Normal mode:
   - ✅ Borders visible
2. Press `i` to enter insert mode:
   - ✅ Borders disappear
   - ✅ Editing is clean without visual distractions
3. Press `Esc` to exit insert mode:
   - ✅ Borders reappear immediately

## Test Case 6: Multi-Format Support

### Test Each File Type

#### .md (Markdown)
- ✅ Shows full Unicode box borders
- ✅ Works with code fences
- ✅ Captures all lines in the code block

#### .qmd (Quarto)
- ✅ Shows full Unicode box borders
- ✅ Works with code fences
- ✅ Same styling as markdown

#### .py (Python)
- ✅ Shows full Unicode borders
- ✅ Responds to `<leader>mts` style changes
- ✅ Completes box around each cell

#### .ipynb (Jupyter notebooks)
- ✅ Shows full Unicode borders
- ✅ Works with cell structure
- ✅ Complete boxes around cells

## Debugging Checklist

If something doesn't work:

### Borders not showing at all
- [ ] Check: `<leader>mtb` (toggle on)
- [ ] Check file type: `:set filetype?`
- [ ] Check if file is supported: `.py`, `.md`, `.qmd`, `.ipynb`
- [ ] Force refresh: `<leader>mtB`

### Borders overlapping with text
- [ ] In markdown: Check if `use_simple_borders_in_markdown = true`
- [ ] Clear and re-render: `:bdelete` then reopen file
- [ ] Check render-markdown plugin isn't conflicting

### Borders in wrong position
- [ ] Markdown: Borders should appear BEFORE opening fence and AFTER closing fence
- [ ] Python: Borders should appear BEFORE first code line and AFTER last code line
- [ ] Save file to trigger re-render

### Incomplete markdown cells
- [ ] Make sure code fences use ` ``` ` (triple backticks)
- [ ] Make sure closing fence is present
- [ ] Force refresh: `<leader>mtB`
- [ ] Check that all lines between fences are captured

## Files to Check

```
lua/config/molten-cell-borders.lua       # Core implementation
lua/plugins/data-tools/molten.lua       # Integration
docs/MOLTEN_CELL_BORDERS.md            # User documentation
```

## Expected Changes

After the fix, you should see:

1. **Markdown files**: Full Unicode box borders around code fences
2. **Python files**: Full Unicode box borders around each cell
3. **Jupyter notebooks**: Full Unicode box borders around cells
4. **Proper cell capture**: All code in the cell is visually contained within the box
5. **Clean display**: Similar visual style to notebook_style.nvim or Jupyter notebooks

## Test Confirmation

Once you verify everything works:

1. Run: `git status` - should show modified files
2. Run: `git diff lua/config/molten-cell-borders.lua` - review changes
3. Run: `git diff lua/plugins/data-tools/molten.lua` - review integration

Then you can safely commit!

## Questions to Ask Yourself

- [ ] Do markdown code blocks show full Unicode box borders?
- [ ] Do Python files show full Unicode box borders?
- [ ] Do Jupyter notebooks show full Unicode box borders?
- [ ] Are there any visual overlaps or clipping?
- [ ] Do all lines of code in a block get contained within the box?
- [ ] Does toggle (`<leader>mtb`) work?
- [ ] Do borders hide in insert mode?
- [ ] Do borders match the style of notebook_style.nvim or Jupyter?

If all checkboxes pass, the fix is working! 🎉
