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
    -- Connection management (using <leader>r for "remote")
    { "<leader>rc", "<cmd>DistantConnect<cr>", desc = "Remote Connect" },
    { "<leader>rd", "<cmd>DistantDisconnect<cr>", desc = "Remote Disconnect" },

    -- File operations
    { "<leader>rf", "<cmd>DistantOpen<cr>", desc = "Remote Open File" },
    { "<leader>re", "<cmd>Telescope distant<cr>", desc = "Remote Explore" },

    -- Directory operations
    { "<leader>rm", "<cmd>DistantMkdir<cr>", desc = "Remote Make Directory" },

    -- Shell
    { "<leader>rt", "<cmd>DistantShell<cr>", desc = "Remote Shell" },

    -- System info
    { "<leader>ri", "<cmd>DistantClientVersion<cr>", desc = "Remote Info" },
  },
}
