-- molten_commands.lua
-- Enhanced Jupyter-like commands for Molten

local M = {}
M.state_dir = ".molten"

-- ====================
-- Helper Functions
-- ====================

-- Helper function to check if Molten is initialized
local function is_molten_active()
  local ok, status = pcall(require, "molten.status")
  if not ok then return false end
  return status.initialized() == "Molten"
end

local function safe_initialized()
  local ok, status = pcall(require, "molten.status")
  if not ok then
    return false, nil
  end
  return status.initialized() == "Molten", status
end

local function safe_kernels()
  local ok, status = pcall(require, "molten.status")
  if not ok then return nil end
  return status.kernels()
end

-- Helper function to find current cell bounds
local function find_cell_bounds()
  local current_line = vim.fn.line('.')
  local total_lines = vim.fn.line('$')

  -- Find start of cell
  local start_line = current_line
  while start_line > 1 do
    local line = vim.fn.getline(start_line - 1)
    if line:match("^%s*$") or line:match("^#") or line:match("^```") then
      break
    end
    start_line = start_line - 1
  end

  -- Find end of cell
  local end_line = current_line
  while end_line < total_lines do
    local line = vim.fn.getline(end_line + 1)
    if line:match("^%s*$") or line:match("^#") or line:match("^```") then
      break
    end
    end_line = end_line + 1
  end

  return start_line, end_line
end

-- ====================
-- State Persistence (from molten_persist.lua)
-- ====================

function M.get_state_path(nb_path)
  local uv = vim.uv or vim.loop
  local dir = vim.fn.fnamemodify(nb_path, ":h")
  local fname = vim.fn.fnamemodify(nb_path, ":t")
  local state_folder = uv.fs_realpath(dir .. "/" .. M.state_dir)
  if not state_folder then
    local ok, err = uv.fs_mkdir(dir .. "/" .. M.state_dir, 493)
    if not ok then
      state_folder = dir
    else
      state_folder = dir .. "/" .. M.state_dir
    end
  end
  return state_folder .. "/" .. fname .. ".molten.json"
end

function M.load_notebook_state(bufnr, nb_path)
  local stpath = M.get_state_path(nb_path)
  if vim.fn.filereadable(stpath) == 1 then
    local in_molten, _ = safe_initialized()
    if in_molten then
      -- Already initialized, can't use MoltenLoad
      vim.notify("Molten already initialized. Cannot load saved state.", vim.log.levels.WARN)
      return
    end
    vim.cmd(("MoltenLoad %s"):format(vim.fn.fnameescape(stpath)))
  end
end

function M.save_notebook_state(bufnr, nb_path)
  local in_molten, _ = safe_initialized()
  if not in_molten then
    return
  end
  local kernels = safe_kernels()
  if kernels == nil or kernels == "" then
    return
  end

  local stpath = M.get_state_path(nb_path)
  vim.cmd(("MoltenSave %s"):format(vim.fn.fnameescape(stpath)))
end

-- ====================
-- Execution Commands
-- ====================

-- Run All Cells
function M.run_all()
  if not is_molten_active() then
    vim.notify("Molten not initialized", vim.log.levels.WARN)
    return
  end

  -- Save current position
  local pos = vim.fn.getpos('.')

  -- Go to beginning of file
  vim.cmd("normal! gg")

  -- Evaluate all by selecting entire file
  vim.cmd("normal! VG")
  vim.cmd("MoltenEvaluateVisual")

  -- Restore position
  vim.fn.setpos('.', pos)

  vim.notify("Running all cells...", vim.log.levels.INFO)
end

-- Run All Above (including current)
function M.run_all_above()
  if not is_molten_active() then
    vim.notify("Molten not initialized", vim.log.levels.WARN)
    return
  end

  local current_line = vim.fn.line('.')
  local pos = vim.fn.getpos('.')

  -- Select from beginning to current line
  vim.cmd("normal! gg")
  vim.fn.setpos('.', {0, current_line, vim.fn.col('$'), 0})
  vim.cmd("normal! V")
  vim.fn.setpos('.', {0, 1, 1, 0})
  vim.cmd("MoltenEvaluateVisual")

  vim.fn.setpos('.', pos)
  vim.notify("Running all cells above...", vim.log.levels.INFO)
end

-- Run All Below (including current)
function M.run_all_below()
  if not is_molten_active() then
    vim.notify("Molten not initialized", vim.log.levels.WARN)
    return
  end

  local current_line = vim.fn.line('.')
  local pos = vim.fn.getpos('.')

  -- Select from current line to end
  vim.fn.setpos('.', {0, current_line, 1, 0})
  vim.cmd("normal! VG")
  vim.cmd("MoltenEvaluateVisual")

  vim.fn.setpos('.', pos)
  vim.notify("Running all cells below...", vim.log.levels.INFO)
end

-- ====================
-- Kernel Management
-- ====================

-- Restart Kernel (wrapper for better UX)
function M.restart_kernel()
  if not is_molten_active() then
    vim.notify("Molten not initialized", vim.log.levels.WARN)
    return
  end

  vim.ui.select(
    {"Keep outputs", "Clear outputs"},
    {prompt = "Restart kernel:"},
    function(choice)
      if choice == "Clear outputs" then
        vim.cmd("MoltenRestart!")
        vim.notify("Kernel restarted (outputs cleared)", vim.log.levels.INFO)
      elseif choice == "Keep outputs" then
        vim.cmd("MoltenRestart")
        vim.notify("Kernel restarted (outputs kept)", vim.log.levels.INFO)
      end
    end
  )
end

-- Restart and Run All
function M.restart_and_run_all()
  if not is_molten_active() then
    vim.notify("Molten not initialized", vim.log.levels.WARN)
    return
  end

  -- Restart with cleared outputs
  vim.cmd("MoltenRestart!")
  vim.notify("Kernel restarted, running all cells...", vim.log.levels.INFO)

  -- Wait a bit for kernel to restart, then run all
  vim.defer_fn(function()
    M.run_all()
  end, 1000)
end

-- Interrupt Kernel (wrapper)
function M.interrupt_kernel()
  if not is_molten_active() then
    vim.notify("Molten not initialized", vim.log.levels.WARN)
    return
  end

  vim.cmd("MoltenInterrupt")
  vim.notify("Kernel interrupted", vim.log.levels.WARN)
end

-- ====================
-- Output Management
-- ====================

-- Clear output of current cell
function M.clear_output()
  if not is_molten_active() then
    vim.notify("Molten not initialized", vim.log.levels.WARN)
    return
  end

  -- Delete the cell's output
  local ok = pcall(vim.cmd, "MoltenDelete")
  if ok then
    vim.notify("Output cleared", vim.log.levels.INFO)
  end
end

-- Clear all outputs
function M.clear_all_outputs()
  if not is_molten_active() then
    vim.notify("Molten not initialized", vim.log.levels.WARN)
    return
  end

  vim.cmd("MoltenDelete!")
  vim.notify("All outputs cleared", vim.log.levels.INFO)
end

-- ====================
-- Cell Manipulation
-- ====================

-- Select current cell
function M.select_cell()
  local start_line, end_line = find_cell_bounds()

  -- Enter visual line mode and select
  vim.fn.setpos('.', {0, start_line, 1, 0})
  vim.cmd("normal! V")
  vim.fn.setpos('.', {0, end_line, 1, 0})
end

-- Yank/Copy current cell
function M.yank_cell()
  local start_line, end_line = find_cell_bounds()

  -- Store in register 'c' for cell
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  vim.g.molten_yanked_cell = lines

  vim.notify(string.format("Yanked cell (%d lines)", #lines), vim.log.levels.INFO)
end

-- Paste cell below current cell
function M.paste_cell_below()
  if not vim.g.molten_yanked_cell then
    vim.notify("No cell in clipboard", vim.log.levels.WARN)
    return
  end

  local _, end_line = find_cell_bounds()

  -- Add blank line and paste
  vim.api.nvim_buf_set_lines(0, end_line, end_line, false, {""})
  vim.api.nvim_buf_set_lines(0, end_line + 1, end_line + 1, false, vim.g.molten_yanked_cell)

  -- Move cursor to pasted cell
  vim.fn.cursor(end_line + 2, 1)

  vim.notify("Cell pasted", vim.log.levels.INFO)
end

-- Split cell at cursor
function M.split_cell()
  local current_line = vim.fn.line('.')
  local start_line, end_line = find_cell_bounds()

  -- Can't split if at boundary
  if current_line == start_line or current_line == end_line then
    vim.notify("Cannot split at cell boundary", vim.log.levels.WARN)
    return
  end

  -- Insert blank line at cursor
  vim.api.nvim_buf_set_lines(0, current_line, current_line, false, {""})

  vim.notify("Cell split", vim.log.levels.INFO)
end

-- Merge with cell below
function M.merge_cell_below()
  local _, end_line = find_cell_bounds()
  local total_lines = vim.fn.line('$')

  if end_line >= total_lines then
    vim.notify("No cell below to merge", vim.log.levels.WARN)
    return
  end

  -- Find next non-empty line
  local next_cell_start = end_line + 1
  while next_cell_start <= total_lines do
    local line = vim.fn.getline(next_cell_start)
    if not line:match("^%s*$") then
      break
    end
    next_cell_start = next_cell_start + 1
  end

  -- Delete empty lines between cells
  if next_cell_start > end_line + 1 then
    vim.api.nvim_buf_set_lines(0, end_line, next_cell_start - 1, false, {})
  end

  vim.notify("Cells merged", vim.log.levels.INFO)
end

-- Move cell up
function M.move_cell_up()
  local start_line, end_line = find_cell_bounds()

  if start_line == 1 then
    vim.notify("Already at top", vim.log.levels.WARN)
    return
  end

  -- Get current cell content
  local cell_lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  -- Find previous cell
  local prev_end = start_line - 1
  while prev_end > 0 and vim.fn.getline(prev_end):match("^%s*$") do
    prev_end = prev_end - 1
  end

  if prev_end == 0 then return end

  local prev_start = prev_end
  while prev_start > 1 do
    local line = vim.fn.getline(prev_start - 1)
    if line:match("^%s*$") or line:match("^#") or line:match("^```") then
      break
    end
    prev_start = prev_start - 1
  end

  -- Delete current cell
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, {})

  -- Insert before previous cell
  vim.api.nvim_buf_set_lines(0, prev_start - 1, prev_start - 1, false, cell_lines)
  vim.api.nvim_buf_set_lines(0, prev_start + #cell_lines - 1, prev_start + #cell_lines - 1, false, {""})

  -- Move cursor
  vim.fn.cursor(prev_start, 1)

  vim.notify("Cell moved up", vim.log.levels.INFO)
end

-- Move cell down
function M.move_cell_down()
  local start_line, end_line = find_cell_bounds()
  local total_lines = vim.fn.line('$')

  if end_line >= total_lines then
    vim.notify("Already at bottom", vim.log.levels.WARN)
    return
  end

  -- Get current cell content
  local cell_lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  -- Find next cell
  local next_start = end_line + 1
  while next_start <= total_lines and vim.fn.getline(next_start):match("^%s*$") do
    next_start = next_start + 1
  end

  if next_start > total_lines then return end

  local next_end = next_start
  while next_end < total_lines do
    local line = vim.fn.getline(next_end + 1)
    if line:match("^%s*$") or line:match("^#") or line:match("^```") then
      break
    end
    next_end = next_end + 1
  end

  -- Delete current cell
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, {})

  -- Calculate new position (accounting for deletion)
  local insert_pos = next_end - (end_line - start_line + 1)

  -- Insert after next cell
  vim.api.nvim_buf_set_lines(0, insert_pos, insert_pos, false, {""})
  vim.api.nvim_buf_set_lines(0, insert_pos + 1, insert_pos + 1, false, cell_lines)

  -- Move cursor
  vim.fn.cursor(insert_pos + 2, 1)

  vim.notify("Cell moved down", vim.log.levels.INFO)
end

-- ====================
-- Navigation
-- ====================

-- Jump to first cell
function M.goto_first_cell()
  vim.cmd("normal! gg")
  -- Find first non-empty line
  local line = 1
  while line <= vim.fn.line('$') do
    if not vim.fn.getline(line):match("^%s*$") then
      vim.fn.cursor(line, 1)
      break
    end
    line = line + 1
  end
end

-- Jump to last cell
function M.goto_last_cell()
  vim.cmd("normal! G")
  -- Find last non-empty line
  local line = vim.fn.line('$')
  while line > 0 do
    if not vim.fn.getline(line):match("^%s*$") then
      vim.fn.cursor(line, 1)
      break
    end
    line = line - 1
  end
end

-- ====================
-- Status Display
-- ====================

-- Show kernel status
function M.show_kernel_status()
  if not is_molten_active() then
    vim.notify("Molten not initialized", vim.log.levels.INFO)
    return
  end

  local ok, status = pcall(require, "molten.status")
  if ok then
    local kernels = status.kernels()
    if kernels and kernels ~= "" then
      vim.notify("Active kernel: " .. kernels, vim.log.levels.INFO)
    else
      vim.notify("No active kernel", vim.log.levels.INFO)
    end
  end
end

return M
