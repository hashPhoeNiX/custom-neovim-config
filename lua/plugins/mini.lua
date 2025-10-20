return {
  {
    'nvim-mini/mini.nvim',
    version = false,
    config = function()
      require('mini.pairs').setup()
      require('mini.starter').setup()
      require('mini.sessions').setup({
        autoread = true,
        verbose = { read = true, write = true, delete = true },
      })
      -- require('mini.notify').setup()
      require('mini.icons').setup()
    end
    -- config = function()
    --   require('mini.nvim').setup({})
    -- end
  },
  -- { 'nvim-mini/mini.icons', version = false, },
  -- { 'nvim-mini/mini.notify', version = false, },
  -- {
  --   'nvim-mini/mini.pairs',
  --   version = false,
  --   config = function()
  --     require('mini.pairs').setup({})
  --   end
  -- },
  -- Mini Starter
  -- {
  --   'nvim-mini/mini.starter',
  --   version = false,
  --   config = function()
  --     require('mini.starter').setup()
  --   end
  -- },
  -- TODO: Mini clue (which key alternative)
}
