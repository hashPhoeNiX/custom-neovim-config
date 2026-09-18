vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set number")
vim.cmd("set relativenumber")
-- Termux has no xclip/wl-copy/pbcopy equivalent; it needs Neovim's built-in
-- g:clipboard provider pointed at termux-clipboard-set/get (from the
-- separate Termux:API package) instead. Elsewhere, Neovim auto-detects the
-- right system tool on its own — unnamedplus alone is enough.
if vim.fn.executable("termux-clipboard-set") == 1 then
  vim.g.clipboard = {
    name = "termux-clipboard",
    copy = { ["+"] = "termux-clipboard-set", ["*"] = "termux-clipboard-set" },
    paste = { ["+"] = "termux-clipboard-get", ["*"] = "termux-clipboard-get" },
    cache_enabled = 0,
  }
end
vim.cmd("set clipboard=unnamedplus")

-- notebook-picker: show a plugin-selection menu (Jupynvim/Molten/Plain) on
-- every .ipynb open. Lives here rather than inside a specific plugin's
-- init() so it always fires regardless of platform or which of those
-- plugins is actually available (e.g. Molten is Darwin-only — see
-- lua/plugins/data-tools/molten.lua and module.nix).
-- BufReadPost is NOT guaranteed to fire here: once Jupynvim has loaded once
-- in a session, its OWN global BufReadCmd hijacks every later .ipynb read
-- directly, and Neovim then skips the normal post-read autocmds entirely
-- (confirmed empirically — only BufReadCmd/BufEnter/BufWinEnter/BufReadPre
-- fired for a notebook opened after the first). That silently skipped BOTH
-- this picker menu (every notebook after the first went straight to
-- whichever plugin was picked first, with no menu at all) and a tag this
-- needs to set (below). BufWinEnter fires reliably regardless, so it's
-- used as the entry point, with a per-buffer guard so it only fires once
-- (BufWinEnter re-fires on every window switch back to an already-picked
-- notebook).
local function notebook_first_show(e)
  if vim.b[e.buf].__notebook_handled then
    return
  end
  vim.b[e.buf].__notebook_handled = true
  -- Snacks pickers/explorer (lua/plugins/snacks.lua) resolve their "main"
  -- (jump-target) window via a search that excludes any window whose
  -- buffer has buftype ~= "" — Jupynvim and Molten's markdown view both
  -- set buftype="acwrite" on notebook buffers, so without this tag a
  -- notebook window is never a valid jump target: a confirmed picker
  -- selection, or an explorer file-open, silently lands in some OTHER
  -- window instead, leaving the notebook untouched — looking like it
  -- "opens in a split".
  vim.b[e.buf].snacks_main = true
  require("config.notebook-picker").pick(e)
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter" }, {
  pattern = { "*.ipynb" },
  callback = notebook_first_show,
})

vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.opt.termguicolors = true

-- Caps the native completion popup AND dropbar.nvim's breadcrumb-pick menu
-- (lua/plugins/dropbar.lua): dropbar falls back to ceil(vim.go.lines / 4)
-- when pumheight is 0 (the default), and anchors that menu at row 0 of the
-- window it's opened in — in a short split that overflowed the window
-- entirely, covering the whole buffer instead of a small dropdown.
vim.opt.pumheight = 10

-- load the session for the current directory
vim.keymap.set("n", "<leader>qS", function() require("persistence").load() end)

-- select a session to load
vim.keymap.set("n", "<leader>qs", function() require("persistence").select() end)

-- load the last session
vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end)

-- stop Persistence => session won't be saved on exit
vim.keymap.set("n", "<leader>qd", function() require("persistence").stop() end)

-- create a keymap for Lazy
vim.keymap.set('n', '<leader>lz', function() require('lazy').home() end, { desc = 'Lazy' })
vim.keymap.set('i', 'jk', '<Esc>', { desc = 'Insert Escape' })
vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Insert Escape' })
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true, desc = "Terminal Escape" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "quarto" },
  callback = function()
    vim.opt_local.conceallevel = 2  -- hide ** _ [[ ]] etc., show clean text
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true  -- wrap at word boundaries, not mid-word
    vim.opt_local.breakindent = true -- preserve indentation on wrapped lines
    vim.opt_local.scrolloff = 8
  end,
})
-- vim.keymap.set('t', 'jk', '<Esc><Esc>', { desc = 'Terminal Escape' })
-- Directional window movements
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to lower window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to upper window' })
vim.keymap.set('t', '<C-k>', '<C-w>k', { desc = 'Move to upper window' })
