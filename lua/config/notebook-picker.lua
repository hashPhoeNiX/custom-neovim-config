-- notebook-picker.lua
-- Shows a selection menu (vim.ui.select) after a .ipynb file is opened so the
-- user can choose which plugin/workflow to use for that buffer.
--
-- Triggered by a BufReadPost autocmd in lua/plugins/data-tools/molten.lua.
-- Molten's auto-init autocmds are commented out there; this file owns the
-- .ipynb open lifecycle instead.

local M = {}

-- ── Molten ──────────────────────────────────────────────────────────────────
-- Mirrors the old `imb` autocmd logic from molten.lua: restores saved state or
-- auto-selects a kernel and imports outputs.
local function open_with_molten(e)
  vim.schedule(function()
    local molten_persist = require("config.molten-persist")
    local stpath = molten_persist.get_state_path(e.file)

    if vim.fn.filereadable(stpath) == 1 then
      pcall(vim.cmd, ("MoltenLoad %s"):format(vim.fn.fnameescape(stpath)))
    else
      local kernels = vim.fn.MoltenAvailableKernels()
      local ok, kernel_name = pcall(function()
        local metadata = vim.json.decode(io.open(e.file, "r"):read("a"))["metadata"]
        return metadata.kernelspec.name
      end)
      if not ok or not vim.tbl_contains(kernels, kernel_name) then
        kernel_name = nil
        local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
        if venv then
          kernel_name = string.match(venv, "/.+/(.+)")
        end
      end
      if kernel_name and vim.tbl_contains(kernels, kernel_name) then
        vim.cmd(("MoltenInit %s"):format(kernel_name))
        vim.cmd("MoltenImportOutput")
      end
    end
  end)
end

-- ── Jupynvim ─────────────────────────────────────────────────────────────────
-- Lazy-loads jupynvim (registers its BufReadCmd), then re-opens the file so
-- jupynvim's BufReadCmd fires and transforms the buffer into a notebook view.
local function open_with_jupynvim(e)
  local ok, err = pcall(require, "jupynvim")
  if not ok then
    vim.notify("jupynvim not available: " .. tostring(err), vim.log.levels.ERROR)
    return
  end
  -- Re-edit the file; jupynvim's BufReadCmd is now registered and will take over.
  vim.cmd("edit " .. vim.fn.fnameescape(e.file))
end

-- ── Picker ───────────────────────────────────────────────────────────────────
local choices = {
  { label = "Jupynvim  (native notebook editor)", handler = open_with_jupynvim },
  { label = "Molten  (interactive cell execution)", handler = open_with_molten },
  { label = "Plain  (raw JSON, no plugin)", handler = function() end },
}

function M.pick(e)
  local labels = vim.tbl_map(function(c) return c.label end, choices)
  vim.ui.select(labels, { prompt = "Open notebook with:" }, function(_, idx)
    if idx and choices[idx] then
      choices[idx].handler(e)
    end
  end)
end

return M
