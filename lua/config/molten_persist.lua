
-- molten_persist.lua
local M = {}

-- Dot folder name (in each notebook directory) to store molten states
M.state_dir = ".molten"

-- Helper: get full path to JSON state file given notebook path
-- e.g. for /path/to/notebook.ipynb → /path/to/.molten_states/notebook.ipynb.json
function M.get_state_path(nb_path)
  local uv = vim.loop
  local dir = vim.fn.fnamemodify(nb_path, ":h")
  local fname = vim.fn.fnamemodify(nb_path, ":t")  -- e.g. “notebook.ipynb”
  local state_folder = uv.fs_realpath(dir .. "/" .. M.state_dir)
  if not state_folder then
    -- create folder
    local ok, err = uv.fs_mkdir(dir .. "/" .. M.state_dir, 493)  -- 493 = 0755
    if not ok then
      -- maybe file exists or permission problem
      -- fallback: use dir itself
      state_folder = dir
    else
      state_folder = dir .. "/" .. M.state_dir
    end
  end
  -- sanitize extension, but we’ll add .json
  return state_folder .. "/" .. fname .. ".molten.json"
end

-- Load (import) state / outputs when opening notebook
function M.load_notebook_state(bufnr, nb_path)
  if not nb_path or nb_path == "" then
    return
  end
  -- First, try to import outputs embedded in the notebook
  local ok1 = pcall(vim.cmd, "MoltenImportOutput")
  if ok1 then
    return
  end
  -- Otherwise, load from saved molten JSON
  local stpath = M.get_state_path(nb_path)
  -- Only load if file exists
  if vim.fn.filereadable(stpath) == 1 then
    vim.cmd(("MoltenLoad %s"):format(vim.fn.fnameescape(stpath)))
  end
end

-- Save state → JSON and export outputs to notebook
function M.save_notebook_state(bufnr, nb_path)
  if not nb_path or nb_path == "" then
    return
  end
  local status = require("molten.status").initialized()
  if status ~= "Molten" then
    return
  end
  -- Save molten JSON state to file
  local stpath = M.get_state_path(nb_path)
  vim.cmd(("MoltenSave %s"):format(vim.fn.fnameescape(stpath)))
  -- Also export outputs into notebook
  vim.cmd("MoltenExportOutput!")
end

function M.setup()
  -- Autocmd: when entering a .ipynb buffer, load state
  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.ipynb",
    callback = function(ev)
      -- schedule to after plugin loaded
      vim.schedule(function()
        M.load_notebook_state(ev.buf, ev.file)
      end)
    end,
  })
  -- Autocmd: after write, save state
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.ipynb",
    callback = function(ev)
      M.save_notebook_state(ev.buf, ev.file)
    end,
  })
  -- Also on exit: before Vim leaves
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      -- Try saving current buffer if it's a notebook
      local buf = vim.api.nvim_get_current_buf()
      local nb_path = vim.api.nvim_buf_get_name(buf)
      if vim.endswith(nb_path, ".ipynb") then
        M.save_notebook_state(buf, nb_path)
      end
    end,
  })
end

return M
