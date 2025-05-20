return {
  { 
    'echasnovski/mini.nvim', version = false,
    -- config = function()
    --   require('mini.nvim').setup({})
    -- end
  },
  { 'echasnovski/mini.icons', version = false, },
  { 'echasnovski/mini.notify', version = false },
  { 
    'echasnovski/mini.pairs', version = false,
    config = function()
      require('mini.pairs').setup({})
    end
  },
}
