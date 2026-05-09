return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'echasnovski/mini.nvim' }, -- nvim-treesitter removed; using Neovim 0.12 built-in treesitter
  -- dependencies = { 'echasnovski/mini.icons' },
  -- dependencies = { 'nvim-tree/nvim-web-devicons' },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    enabled = true,
    -- ignore = function(buf)
    --   -- Disable for .ipynb files or buffers with "jupyter" in the name
    --   local filename = vim.api.nvim_buf_get_name(buf)
    --   return string.match(filename, "%.ipynb$") or string.match(filename, "jupyter")
    -- end,

    -- For molten
    code = {
      enabled = true,
      conceal_delimiters = false,
      language = true,
      border = 'thick',
    },
    render_modes = true, -- Default: { 'n', 'c', 't' } -- normal, command, terminal
    completions = {
      blink = {
        enabled = true
      },
    },
    -- html parser is available via COLLATED_TS_GRAMMARS; re-enabled.
    -- latex disabled: parser exists but no latex/pdflatex executable in this build.
    latex = { enabled = false }, -- no latex tools (pdflatex etc.) in extraPackages
  },
}
