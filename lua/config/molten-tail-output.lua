-- molten-tail-output.lua
-- Post-process molten outputs to show tail instead of head

local M = {}

-- Configuration
M.config = {
  enabled = true,
  max_lines = 50,  -- Maximum lines to keep (tail)
  min_lines_to_truncate = 100,  -- Only truncate if output exceeds this
  delay_ms = 500,  -- Delay after execution to process output
}

-- Find all molten output buffers
local function find_output_buffers()
  local output_bufs = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      -- Molten output buffers typically have specific characteristics
      -- They're often unnamed or have a specific pattern
      local buf_lines = vim.api.nvim_buf_line_count(buf)

      -- Check if this looks like an output buffer
      -- (unnamed, non-file buffers with content)
      if name == "" or name:match("molten") then
        local ok, lines = pcall(vim.api.nvim_buf_get_lines, buf, 0, -1, false)
        if ok and #lines > 0 then
          table.insert(output_bufs, buf)
        end
      end
    end
  end
  return output_bufs
end

-- Truncate buffer to show only the tail
local function truncate_to_tail(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local total_lines = vim.api.nvim_buf_line_count(bufnr)

  -- Only truncate if output is long enough
  if total_lines <= M.config.min_lines_to_truncate then
    return
  end

  -- Keep only the last max_lines lines
  local keep_from = total_lines - M.config.max_lines
  if keep_from < 0 then
    keep_from = 0
  end

  -- Get the tail lines
  local ok, tail_lines = pcall(vim.api.nvim_buf_get_lines, bufnr, keep_from, -1, false)
  if not ok then
    return
  end

  -- Add truncation indicator at the top
  local truncated_count = total_lines - #tail_lines
  local indicator = string.format("... [%d lines truncated, showing last %d lines] ...",
                                  truncated_count, #tail_lines)
  table.insert(tail_lines, 1, indicator)
  table.insert(tail_lines, 2, "")

  -- Replace buffer content with tail
  pcall(vim.api.nvim_buf_set_lines, bufnr, 0, -1, false, tail_lines)
end

-- Process all current output buffers
local function process_outputs()
  if not M.config.enabled then
    return
  end

  -- Try to access molten's internal output buffers
  -- This is a heuristic approach since molten doesn't expose them directly
  local ok, molten_status = pcall(require, "molten.status")
  if not ok or molten_status.initialized() ~= "Molten" then
    return
  end

  -- Look for output buffers by examining all buffers
  -- Molten uses scratch buffers for output
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
      local modifiable = vim.api.nvim_get_option_value("modifiable", { buf = buf })

      -- Molten output buffers are typically nofile/nowrite and modifiable
      if buftype == "nofile" or buftype == "acwrite" then
        truncate_to_tail(buf)
      end
    end
  end
end

-- Wrapper for evaluation commands that post-processes output
function M.evaluate_with_tail(eval_func)
  -- Execute the original evaluation
  eval_func()

  -- Wait for output to be generated, then process it
  vim.defer_fn(function()
    process_outputs()
  end, M.config.delay_ms)
end

-- Setup function to wrap molten commands
function M.setup(user_config)
  M.config = vim.tbl_deep_extend("force", M.config, user_config or {})

  if not M.config.enabled then
    return
  end

  -- Create commands for manual processing
  vim.api.nvim_create_user_command("MoltenTailOutput", function()
    process_outputs()
  end, {
    desc = "Process molten outputs to show tail",
  })

  vim.api.nvim_create_user_command("MoltenTailToggle", function()
    M.config.enabled = not M.config.enabled
    vim.notify(
      string.format("Molten tail output: %s", M.config.enabled and "enabled" or "disabled"),
      vim.log.levels.INFO
    )
  end, {
    desc = "Toggle molten tail output processing",
  })

  -- Try to hook into molten evaluation
  -- Since molten doesn't expose hooks for output generation,
  -- we'll use a timer-based approach
  if M.config.enabled then
    -- Set up autocmd to process outputs after evaluation commands
    local group = vim.api.nvim_create_augroup("MoltenTailOutput", { clear = true })

    -- Watch for buffer changes in molten output windows
    vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"}, {
      group = group,
      callback = function(ev)
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = ev.buf })
        if buftype == "nofile" or buftype == "acwrite" then
          -- Debounced processing
          vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(ev.buf) then
              truncate_to_tail(ev.buf)
            end
          end, M.config.delay_ms)
        end
      end,
    })
  end
end

-- Keybinding-friendly wrappers
function M.evaluate_line_tail()
  vim.cmd("MoltenEvaluateLine")
  vim.defer_fn(process_outputs, M.config.delay_ms)
end

function M.evaluate_visual_tail()
  vim.cmd("MoltenEvaluateVisual")
  vim.defer_fn(process_outputs, M.config.delay_ms)
end

function M.reevaluate_cell_tail()
  vim.cmd("MoltenReevaluateCell")
  vim.defer_fn(process_outputs, M.config.delay_ms)
end

return M
