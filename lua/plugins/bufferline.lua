return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = 'nvim-tree/nvim-web-devicons',
  opts = {
    options = {
      mode = 'buffers',
      themable = true,
      numbers = 'none',
      indicator = { style = 'underline' }, -- VSCode-style active-tab bar
      separator_style = 'thin',
      always_show_bufferline = true,
      show_buffer_close_icons = true,
      show_close_icon = false,
      color_icons = true,
      diagnostics = 'nvim_lsp',
      diagnostics_indicator = function(count)
        return ' (' .. count .. ')'
      end,
      offsets = {
        {
          filetype = 'neo-tree',
          text = 'File Explorer',
          text_align = 'center',
          separator = true,
        },
      },
    },
    -- Explicit, colorscheme-independent overrides: whichever of
    -- github-theme/catppuccin ends up active (lua/plugins/github-themes.lua
    -- currently sets github_dark_dimmed), the auto-derived bufferline colors
    -- were too low-contrast to read at a glance.
    highlights = {
      fill = { bg = '#0d1117' },
      background = { fg = '#8b949e', bg = '#161b22' },
      buffer_visible = { fg = '#c9d1d9', bg = '#161b22' },
      buffer_selected = { fg = '#ffffff', bg = '#0d1117', bold = true, italic = false },
      separator = { fg = '#0d1117', bg = '#161b22' },
      separator_selected = { fg = '#0d1117', bg = '#0d1117' },
      indicator_selected = { fg = '#58a6ff', bg = '#0d1117' },
      modified = { fg = '#d29922', bg = '#161b22' },
      modified_selected = { fg = '#d29922', bg = '#0d1117' },
      modified_visible = { fg = '#d29922', bg = '#161b22' },
    },
  },
}

