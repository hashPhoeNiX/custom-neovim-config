-- molten-cell-borders.lua
-- Visual cell borders for Molten notebooks
-- Renders Unicode box-drawing characters around detected cells

local M = {}

-- Default configuration
local config = {
  enabled = true,
  border_style = "solid",
  show_in_insert = false,
  cell_width_percentage = 90,
  min_cell_width = 40,
  max_cell_width = 120,
  colors = {
    border = "#6272A4",
    -- Status colors for future use
    executed = "#50FA7B",
    pending = "#FFB86C",
    error = "#FF5555",
  },
  border_chars = {
    solid = {
      top_left = "┌",
      top_right = "┐",
      bottom_left = "└",
      bottom_right = "┘",
      horizontal = "─",
      vertical = "│",
    },
    dashed = {
      top_left = "┏",
      top_right = "┓",
      bottom_left = "┗",
      bottom_right = "┛",
      horizontal = "━",
      vertical = "┃",
    },
    double = {
      top_left = "╔",
      top_right = "╗",
      bottom_left = "╚",
      bottom_right = "╝",
      horizontal = "═",
      vertical = "║",
    },
  },
}

-- State tracking
local state = {
  buffers = {},           -- Track state per buffer
  border_extmarks = {},   -- Track extmark IDs per buffer
  render_timer = nil,
  insert_mode_active = false,
}

---@param opts table Configuration options
function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  -- Set up highlights
  M._setup_highlights()

  -- Create autocmds for border management
  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    group = vim.api.nvim_create_augroup("MoltenCellBorders", { clear = true }),
    pattern = { "*.ipynb", "*.md", "*.qmd", "*.py" },
    callback = function(event)
      M._on_buffer_enter(event.buf)
    end,
  })

  -- Hide borders in insert mode
  vim.api.nvim_create_autocmd({ "InsertEnter" }, {
    group = "MoltenCellBorders",
    callback = function()
      if config.show_in_insert == false then
        M._hide_borders(vim.api.nvim_get_current_buf())
        state.insert_mode_active = true
      end
    end,
  })

  -- Show borders when leaving insert mode
  vim.api.nvim_create_autocmd({ "InsertLeave" }, {
    group = "MoltenCellBorders",
    callback = function()
      if config.show_in_insert == false then
        M._show_borders(vim.api.nvim_get_current_buf())
        state.insert_mode_active = false
      end
    end,
  })

  -- Re-render on buffer write (in case cell structure changed)
  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    group = "MoltenCellBorders",
    pattern = { "*.ipynb", "*.md", "*.qmd", "*.py" },
    callback = function(event)
      if config.enabled then
        M.render_borders(event.buf)
      end
    end,
  })
end

---Setup highlight groups
function M._setup_highlights()
  vim.api.nvim_set_hl(0, "MoltenCellBorder", {
    fg = config.colors.border,
  })
  vim.api.nvim_set_hl(0, "MoltenCellBorderExecuted", {
    fg = config.colors.executed,
  })
  vim.api.nvim_set_hl(0, "MoltenCellBorderPending", {
    fg = config.colors.pending,
  })
  vim.api.nvim_set_hl(0, "MoltenCellBorderError", {
    fg = config.colors.error,
  })
end

---Find cell boundaries starting from current line
---@param bufnr integer Buffer number
---@param start_line integer Starting line to search from (1-indexed)
---@return integer, integer Start and end line of cell (1-indexed)
function M._find_cell_bounds(bufnr, start_line)
  local total_lines = vim.api.nvim_buf_line_count(bufnr)

  -- Find start of cell (search backwards for boundary marker)
  local cell_start = start_line
  while cell_start > 1 do
    local line = vim.api.nvim_buf_get_lines(bufnr, cell_start - 2, cell_start - 1, false)[1] or ""
    -- Stop at empty line, markdown heading, or code fence
    if line:match("^%s*$") or line:match("^#") or line:match("^```") then
      break
    end
    cell_start = cell_start - 1
  end

  -- Find end of cell (search forwards for boundary marker)
  local cell_end = start_line
  while cell_end < total_lines do
    local line = vim.api.nvim_buf_get_lines(bufnr, cell_end, cell_end + 1, false)[1] or ""
    -- Stop at empty line, markdown heading, or code fence
    if line:match("^%s*$") or line:match("^#") or line:match("^```") then
      break
    end
    cell_end = cell_end + 1
  end

  return cell_start, cell_end
end

---Find all cells in buffer
---@param bufnr integer Buffer number
---@return table Array of cell bounds {start, end}
function M._find_all_cells(bufnr)
  local total_lines = vim.api.nvim_buf_line_count(bufnr)
  local cells = {}
  local current_line = 1

  while current_line <= total_lines do
    local line = vim.api.nvim_buf_get_lines(bufnr, current_line - 1, current_line, false)[1] or ""

    -- Skip empty lines
    if not line:match("^%s*$") then
      local cell_start, cell_end = M._find_cell_bounds(bufnr, current_line)

      -- Add cell if not already added
      if #cells == 0 or cells[#cells].end_ < cell_start then
        table.insert(cells, {
          start = cell_start,
          end_ = cell_end,
        })
      end

      current_line = cell_end + 1
    else
      current_line = current_line + 1
    end
  end

  return cells
end

---Calculate cell width based on config
---@return integer Width in characters
function M._calculate_cell_width()
  local win_width = vim.api.nvim_win_get_width(0)
  local width = math.floor(win_width * config.cell_width_percentage / 100)
  width = math.max(config.min_cell_width, math.min(width, config.max_cell_width))
  return width
end

---Create top border virt text
---@param width integer Cell width
---@return string Virt text for top border
function M._create_top_border(width)
  local chars = config.border_chars[config.border_style]
  local border = chars.top_left
  local content_width = width - 2 -- Account for left and right corners
  border = border .. string.rep(chars.horizontal, content_width) .. chars.top_right
  return border
end

---Create bottom border virt text
---@param width integer Cell width
---@return string Virt text for bottom border
function M._create_bottom_border(width)
  local chars = config.border_chars[config.border_style]
  local border = chars.bottom_left
  local content_width = width - 2
  border = border .. string.rep(chars.horizontal, content_width) .. chars.bottom_right
  return border
end

---Render borders for a cell
---@param bufnr integer Buffer number
---@param cell_start integer Cell start line (1-indexed)
---@param cell_end integer Cell end line (1-indexed)
function M._render_cell_borders(bufnr, cell_start, cell_end)
  if not state.buffers[bufnr] then
    state.buffers[bufnr] = {}
    state.border_extmarks[bufnr] = {}
  end

  local width = M._calculate_cell_width()
  local top_border = M._create_top_border(width)
  local bottom_border = M._create_bottom_border(width)

  -- Add top border
  local top_mark = vim.api.nvim_buf_set_extmark(bufnr, vim.api.nvim_create_namespace("molten_cell_borders"), cell_start - 1, 0, {
    virt_lines = { { { top_border, "MoltenCellBorder" } } },
    virt_lines_leftcol = true,
  })

  -- Add bottom border
  local bottom_mark = vim.api.nvim_buf_set_extmark(bufnr, vim.api.nvim_create_namespace("molten_cell_borders"), cell_end - 1, 0, {
    virt_lines = { { { bottom_border, "MoltenCellBorder" } } },
    virt_lines_leftcol = true,
  })

  table.insert(state.border_extmarks[bufnr], top_mark)
  table.insert(state.border_extmarks[bufnr], bottom_mark)
end

---Clear all borders in a buffer
---@param bufnr integer Buffer number
function M._clear_borders(bufnr)
  local ns = vim.api.nvim_create_namespace("molten_cell_borders")
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  state.border_extmarks[bufnr] = {}
end

---Render all borders in current buffer
---@param bufnr integer Buffer number (optional, defaults to current)
function M.render_borders(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if not config.enabled then
    return
  end

  -- Check if buffer is in supported filetype
  local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
  if not vim.tbl_contains({ "python", "markdown", "quarto", "ipynb" }, ft) then
    return
  end

  -- Debounce rendering to avoid excessive updates
  if state.render_timer then
    vim.fn.timer_stop(state.render_timer)
  end

  state.render_timer = vim.fn.timer_start(100, function()
    M._clear_borders(bufnr)
    local cells = M._find_all_cells(bufnr)

    for _, cell in ipairs(cells) do
      M._render_cell_borders(bufnr, cell.start, cell.end_)
    end

    state.render_timer = nil
  end)
end

---Hide borders temporarily
---@param bufnr integer Buffer number
function M._hide_borders(bufnr)
  local ns = vim.api.nvim_create_namespace("molten_cell_borders")
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

---Show borders again
---@param bufnr integer Buffer number
function M._show_borders(bufnr)
  if not config.enabled then
    return
  end
  M.render_borders(bufnr)
end

---Handle buffer enter event
---@param bufnr integer Buffer number
function M._on_buffer_enter(bufnr)
  if config.enabled then
    M.render_borders(bufnr)
  end
end

---Toggle borders on/off
function M.toggle_borders()
  config.enabled = not config.enabled
  local bufnr = vim.api.nvim_get_current_buf()

  if config.enabled then
    M.render_borders(bufnr)
    vim.notify("Molten cell borders enabled", vim.log.levels.INFO)
  else
    M._clear_borders(bufnr)
    vim.notify("Molten cell borders disabled", vim.log.levels.INFO)
  end
end

---Refresh borders in current buffer
function M.refresh_borders()
  local bufnr = vim.api.nvim_get_current_buf()
  M.render_borders(bufnr)
  vim.notify("Cell borders refreshed", vim.log.levels.INFO)
end

---Change border style
---@param style string Border style: 'solid', 'dashed', or 'double'
function M.set_border_style(style)
  if not config.border_chars[style] then
    vim.notify("Invalid border style: " .. style, vim.log.levels.ERROR)
    return
  end
  config.border_style = style
  M.refresh_borders()
end

return M
