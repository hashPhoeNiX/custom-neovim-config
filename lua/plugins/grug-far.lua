return {
  "MagicDuck/grug-far.nvim",
  event = "VeryLazy",
  opts = {
    headerMaxWidth = 80,
    engine = "ripgrep",
    engineParams = {
      "--smart-case",
    },
    startInInsertMode = true,
    -- Default flags for ripgrep
    -- --hidden: search hidden files
    -- --fixed-strings: treat pattern as literal string (disable regex by default)
    ripgrep = {
      extraArgs = "--hidden --fixed-strings",
    },
    -- Exclude common directories
    filesFilter = "!.git/",
    folding = {
      enabled = true,
      foldopen = true,
    },
    keymaps = {
      replace = { n = "<C-r>" },
      qflist = { n = "<localleader>q" },
      syncLocations = { n = "<localleader>s" },
      syncLine = { n = "<localleader>l" },
      close = { n = "<localleader>c" },
      historyOpen = { n = "<localleader>h" },
      historyAdd = { n = "<localleader>a" },
      refresh = { n = "<localleader>r" },
      gotoLocation = { n = "<enter>" },
      abort = { n = "<localleader>b" },
    },
  },
  keys = {
    {
      "<leader>sr",
      function()
        require("grug-far").open()
      end,
      mode = { "n", "v" },
      desc = "Search and replace",
    },
    {
      "<leader>sR",
      function()
        require("grug-far").open({
          prefills = {
            search = vim.fn.expand("<cword>"),
          },
        })
      end,
      desc = "Search and replace (word under cursor)",
    },
    {
      "<leader>sf",
      function()
        require("grug-far").open({
          prefills = {
            paths = vim.fn.expand("%"),
          },
        })
      end,
      desc = "Search and replace in current file",
    },
  },
}
