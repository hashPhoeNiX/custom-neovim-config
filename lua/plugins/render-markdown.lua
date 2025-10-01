return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
  -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
  -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    enabled = true,
    ignore = function(buf)
      -- Disable for .ipynb files or buffers with "jupyter" in the name
      local filename = vim.api.nvim_buf_get_name(buf)
      return string.match(filename, "%.ipynb$") or string.match(filename, "jupyter")
    end,
    render_modes = true, -- Default: { 'n', 'c', 't' } -- normal, command, terminal
    completions = {
      blink = {
        enabled = true
      },
    }
  },
}
