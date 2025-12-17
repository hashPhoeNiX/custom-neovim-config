return {
  "chipsenkbeil/distant.nvim",
  branch = "v0.3",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("distant"):setup({
      -- Use SSH by default
      ["*"] = {
        ssh = {
          -- Use your SSH config
          config_file = vim.fn.expand("~/.ssh/config"),
        },
      },
    })
  end,

  keys = {
    -- Connection management
    { "<leader>dc", "<cmd>DistantConnect<cr>", desc = "Distant Connect" },
    { "<leader>dd", "<cmd>DistantDisconnect<cr>", desc = "Distant Disconnect" },

    -- File operations (matches sshfs.nvim pattern)
    { "<leader>df", "<cmd>DistantOpen<cr>", desc = "Distant Open File" },
    { "<leader>de", "<cmd>Telescope distant<cr>", desc = "Distant Explore" },

    -- Directory operations
    { "<leader>dm", "<cmd>DistantMkdir<cr>", desc = "Distant Make Directory" },

    -- Shell
    { "<leader>dt", "<cmd>DistantShell<cr>", desc = "Distant Shell" },

    -- System info
    { "<leader>di", "<cmd>DistantClientVersion<cr>", desc = "Distant Info" },
  },
}
