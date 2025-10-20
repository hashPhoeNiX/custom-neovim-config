-- molten_persist.lua
local M = {}
M.state_dir = ".molten"

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
  local in_molten, _ = safe_initialized()
  local kernels = safe_kernels()
  -- if molten not active or no kernel, skip
  if not in_molten or kernels == nil or kernels == "" then
    return
  end

  -- if notebook has embedded outputs, import
  local ok1 = pcall(vim.cmd, "MoltenImportOutput")
  if ok1 then
    return
  end

  local stpath = M.get_state_path(nb_path)
  if vim.fn.filereadable(stpath) == 1 then
    vim.cmd(("MoltenLoad %s"):format(vim.fn.fnameescape(stpath)))
  end
end

function M.save_notebook_state(bufnr, nb_path)
  local in_molten, _ = safe_initialized()
  if not in_molten then
    return
  end
  local kernels = safe_kernels()
  -- optionally, require at least one kernel
  if kernels == nil or kernels == "" then
    return
  end

  local stpath = M.get_state_path(nb_path)
  vim.cmd(("MoltenSave %s"):format(vim.fn.fnameescape(stpath)))
  -- Remove MoltenExportOutput to avoid nbformat compatibility issues
  -- vim.cmd("MoltenExportOutput!")
end

function M.setup()
  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.ipynb",
    callback = function(ev)
      vim.schedule(function()
        M.load_notebook_state(ev.buf, ev.file)
      end)
    end,
  })

  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.ipynb",
    callback = function(ev)
      M.save_notebook_state(ev.buf, ev.file)
    end,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      local name = vim.api.nvim_buf_get_name(buf)
      if vim.endswith(name, ".ipynb") then
        M.save_notebook_state(buf, name)
      end
    end,
  })
end

return M
