-- DISABLED: Replaced by distant.nvim (better macOS support, no kernel extensions)
return {
  "inhesrom/remote-ssh.nvim",
  enabled = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("remote-ssh").setup({})

    -- Key mappings for common operations
    vim.keymap.set("n", "<leader>rs", function()
      vim.cmd("RemoteSshOpen")
    end, { noremap = true, silent = true, desc = "Open remote-ssh file browser" })

    vim.keymap.set("n", "<leader>rc", function()
      vim.cmd("RemoteSshConnect")
    end, { noremap = true, silent = true, desc = "Connect to remote-ssh server" })
  end,
}
