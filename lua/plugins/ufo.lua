return {
  "kevinhwang91/nvim-ufo",
  dependencies = {
    "kevinhwang91/promise-async",
  },
  event = "VeryLazy",
  opts = {
    -- Use treesitter as primary, fallback to indent
    provider_selector = function(bufnr, filetype, buftype)
      return { "treesitter", "indent" }
    end,
  },
  config = function(_, opts)
    require("ufo").setup(opts)

    -- Folding options
    vim.o.foldcolumn = "1" -- Show fold column
    vim.o.foldlevel = 99 -- Open all folds by default
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    -- Option 1: Leader-based for open/close all
    vim.keymap.set("n", "<leader>zo", require("ufo").openAllFolds, { desc = "Open all folds" })
    vim.keymap.set("n", "<leader>zc", require("ufo").closeAllFolds, { desc = "Close all folds" })

    -- Option 4: Simple peek with zp
    vim.keymap.set("n", "zp", function()
      local winid = require("ufo").peekFoldedLinesUnderCursor()
      if not winid then
        vim.notify("No fold found under cursor", vim.log.levels.INFO)
      end
    end, { desc = "Peek fold" })

    -- Keep vim's built-in za (toggle), zr (reduce), zm (more folds) etc.
  end,
}
