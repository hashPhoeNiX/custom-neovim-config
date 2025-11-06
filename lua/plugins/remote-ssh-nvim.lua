return {
  "inhesrom/remote-ssh.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",       -- Required dependency
    "nvim-telescope/telescope.nvim", -- For file browser
  },
  config = function()
    require("remote-ssh").setup()

    -- Key mappings for common operations
    vim.keymap.set("n", "<leader>rs", function()
      vim.cmd("RemoteSshOpen")
    end, { noremap = true, silent = true, desc = "Open remote-ssh file browser" })

    vim.keymap.set("n", "<leader>rc", function()
      vim.cmd("RemoteSshConnect")
    end, { noremap = true, silent = true, desc = "Connect to remote-ssh server" })
  end,
}
