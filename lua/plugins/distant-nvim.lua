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

    -- Set up keymaps directly (nixCats doesn't use lazy.nvim's lazy loading)
    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }

    -- Connection management (using <leader>r for "remote")
    map("n", "<leader>rc", "<cmd>DistantConnect<cr>", vim.tbl_extend("force", opts, { desc = "Remote Connect" }))
    map("n", "<leader>rd", "<cmd>DistantDisconnect<cr>", vim.tbl_extend("force", opts, { desc = "Remote Disconnect" }))

    -- File operations
    map("n", "<leader>rf", "<cmd>DistantOpen<cr>", vim.tbl_extend("force", opts, { desc = "Remote Open File" }))
    map("n", "<leader>re", "<cmd>Telescope distant<cr>", vim.tbl_extend("force", opts, { desc = "Remote Explore" }))

    -- Directory operations
    map("n", "<leader>rm", "<cmd>DistantMkdir<cr>", vim.tbl_extend("force", opts, { desc = "Remote Make Directory" }))

    -- Shell
    map("n", "<leader>rt", "<cmd>DistantShell<cr>", vim.tbl_extend("force", opts, { desc = "Remote Shell" }))

    -- System info
    map("n", "<leader>ri", "<cmd>DistantClientVersion<cr>", vim.tbl_extend("force", opts, { desc = "Remote Info" }))
  end,
}
