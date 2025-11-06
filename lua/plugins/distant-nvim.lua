return {
  "chipsenkbeil/distant.nvim",
  branch = "v0.3",           -- Use stable v0.3 branch
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required dependency
  },
  config = function()
    require("distant"):setup()

    -- Key mappings for common distant operations
    vim.keymap.set("n", "<leader>dc", function()
      vim.cmd("DistantConnect")
    end, { noremap = true, silent = true, desc = "Connect to distant server" })

    vim.keymap.set("n", "<leader>do", function()
      vim.cmd("DistantOpen")
    end, { noremap = true, silent = true, desc = "Open distant file" })
  end,
}
