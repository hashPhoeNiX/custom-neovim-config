return {
  "chipsenkbeil/distant.nvim",
  branch = "v0.3",                     -- Use stable v0.3 branch
  dependencies = {
    "nvim-lua/plenary.nvim",           -- Required dependency
  },
  config = function()
    require("distant").setup {
      -- Install distant binary automatically if missing
      install = {
        skip = false,
        force = false,
      },
      -- Network settings
      network = {
        timeout = 30000,               -- Connection timeout in ms
      },
      -- Server settings
      servers = {
        -- Default settings for all servers
        ["*"] = {
          connect_timeout = 30,
          ssh = {
            -- Use system SSH key
            identities = { vim.fn.expand("$HOME") .. "/.ssh/id_rsa" },
          },
        },
      },
    }

    -- Key mappings for common distant operations
    vim.keymap.set("n", "<leader>do", function()
      require("distant").open()
    end, { noremap = true, silent = true, desc = "Open distant file" })

    vim.keymap.set("n", "<leader>dc", function()
      require("distant").connect()
    end, { noremap = true, silent = true, desc = "Connect to distant server" })
  end,
}
