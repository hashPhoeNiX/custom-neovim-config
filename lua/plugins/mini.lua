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

      -- Mini Clue (which-key alternative) - DISABLED, using which-key instead
      -- local miniclue = require('mini.clue')
      -- miniclue.setup({
      --   triggers = {
      --     -- Leader triggers
      --     { mode = 'n', keys = '<Leader>' },
      --     { mode = 'x', keys = '<Leader>' },
      --     { mode = 'n', keys = '<LocalLeader>' },
      --     { mode = 'x', keys = '<LocalLeader>' },
      --
      --     -- Built-in completion
      --     { mode = 'i', keys = '<C-x>' },
      --
      --     -- `g` key
      --     { mode = 'n', keys = 'g' },
      --     { mode = 'x', keys = 'g' },
      --
      --     -- Marks
      --     { mode = 'n', keys = "'" },
      --     { mode = 'n', keys = '`' },
      --     { mode = 'x', keys = "'" },
      --     { mode = 'x', keys = '`' },
      --
      --     -- Registers
      --     { mode = 'n', keys = '"' },
      --     { mode = 'x', keys = '"' },
      --     { mode = 'i', keys = '<C-r>' },
      --     { mode = 'c', keys = '<C-r>' },
      --
      --     -- Window commands
      --     { mode = 'n', keys = '<C-w>' },
      --
      --     -- `z` key
      --     { mode = 'n', keys = 'z' },
      --     { mode = 'x', keys = 'z' },
      --
      --     -- Bracketed
      --     { mode = 'n', keys = '[' },
      --     { mode = 'n', keys = ']' },
      --   },
      --
      --   clues = {
      --     -- Enhance this by adding descriptions for <Leader> mapping groups
      --     miniclue.gen_clues.builtin_completion(),
      --     miniclue.gen_clues.g(),
      --     miniclue.gen_clues.marks(),
      --     miniclue.gen_clues.registers(),
      --     miniclue.gen_clues.windows(),
      --     miniclue.gen_clues.z(),
      --
      --     -- Custom leader group labels
      --     { mode = 'n', keys = '<Leader>m', desc = '+Molten' },
      --     { mode = 'n', keys = '<Leader>mr', desc = '+Run' },
      --     { mode = 'n', keys = '<Leader>mk', desc = '+Kernel' },
      --     { mode = 'n', keys = '<Leader>mc', desc = '+Cell' },
      --     { mode = 'n', keys = '<Leader>mn', desc = '+Navigate' },
      --     { mode = 'n', keys = '<Leader>mo', desc = '+Output' },
      --   },
      --
      --   window = {
      --     delay = 300,
      --     config = {
      --       width = 'auto',
      --       border = 'rounded',
      --     },
      --   },
      -- })
    end
  },
}
