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

-- Tries the notebook's own kernelspec.name first, then $VIRTUAL_ENV/
-- $CONDA_PREFIX's basename as a fallback guess. Notifies instead of silently
-- doing nothing when no available kernel matches either.
local function molten_fresh_init(e)
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
  else
    vim.notify(
      "Molten: no matching kernel found for this notebook (checked its own "
        .. "kernelspec and $VIRTUAL_ENV/$CONDA_PREFIX). Run :MoltenInit manually.",
      vim.log.levels.WARN
    )
  end
end

-- Converts the raw .ipynb JSON into a readable markdown+code view so Molten's
-- cell-based <CR> keymap (blank-line/heading/fence boundaries) has fenced
-- code blocks to work with instead of raw JSON text. Calls the `jupytext`
-- CLI directly rather than using jupytext.nvim: that plugin hijacks *every*
-- *.ipynb via a global BufReadCmd the instant it's set up, which fires
-- before this picker's own BufReadPost and silently broke it — exactly the
-- bug that got jupytext.nvim removed from this config. Read-only by design:
-- :w is intercepted with a warning instead of overwriting the notebook's
-- real JSON with this markdown text. Persist changes via the source .ipynb
-- or Molten's own state/export commands.
local function render_as_markdown(e)
  local result = vim
    .system({ "jupytext", "--to", "markdown", "--output", "-", e.file }, { text = true })
    :wait()
  if result.code ~= 0 or not result.stdout or result.stdout == "" then
    vim.notify(
      "Molten: jupytext conversion failed (exit " .. tostring(result.code) .. "); showing raw JSON.",
      vim.log.levels.WARN
    )
    return
  end

  local lines = vim.split(result.stdout, "\n", { plain = true })
  if lines[#lines] == "" then
    table.remove(lines)
  end

  vim.bo.modifiable = true
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.bo.filetype = "markdown"
  vim.bo.modified = false
  vim.bo.buftype = "acwrite"
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = 0,
    callback = function()
      vim.bo.modified = false
      vim.notify(
        "This is a read-only jupytext view; :w does not save back to the .ipynb."
          .. " Edit the .ipynb source directly to persist changes.",
        vim.log.levels.WARN
      )
    end,
  })
end

local function open_with_molten(e)
  vim.schedule(function()
    render_as_markdown(e)

    local molten_persist = require("config.molten-persist")
    local stpath = molten_persist.get_state_path(e.file)

    if vim.fn.filereadable(stpath) == 1 then
      -- MoltenLoad refuses to load state whose saved checksum no longer
      -- matches the current file (e.g. the notebook was edited since the
      -- state was saved). That used to fail silently here — fall back to a
      -- fresh init instead of leaving the buffer with no kernel at all.
      local ok, err = pcall(vim.cmd, ("MoltenLoad %s"):format(vim.fn.fnameescape(stpath)))
      if not ok then
        vim.notify(
          "Molten: saved state failed to load (" .. tostring(err) .. "); starting a fresh kernel instead.",
          vim.log.levels.WARN
        )
        molten_fresh_init(e)
      end
    else
      molten_fresh_init(e)
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
  -- <leader>np re-invokes the picker on demand ("notebook picker" — jupynvim's
  -- own default keymaps already claim most of <leader>n*: a/b/c/d/i/j/k/m/o/
  -- s/x/y and uppercase variants, "p" is free). Force a fresh re-read from
  -- disk first: a prior choice may have left the buffer in a state other
  -- handlers don't expect (e.g. Molten's converted markdown view), and each
  -- handler assumes it's starting from the notebook's actual raw content.
  -- Don't call M.pick(e) again here: molten.lua's BufReadPost autocmd on
  -- *.ipynb already fires from this forced reload and calls pick() itself.
  -- Doing both raced two picker UIs against each other, and the second one
  -- opening would immediately close the first before it could be used.
  vim.keymap.set("n", "<leader>np", function()
    vim.cmd("edit! " .. vim.fn.fnameescape(e.file))
  end, { buffer = e.buf, desc = "Switch notebook plugin (Jupynvim/Molten/Plain)" })

  local labels = vim.tbl_map(function(c) return c.label end, choices)
  vim.ui.select(labels, { prompt = "Open notebook with:" }, function(_, idx)
    if idx and choices[idx] then
      choices[idx].handler(e)
    end
  end)
end

return M
