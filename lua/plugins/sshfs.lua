return {
  "uhs-robert/sshfs.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("sshfs").setup({
      mounts = {
        base_dir = vim.fn.expand("~/mnt"), -- Where to create mount points
        unmount_on_exit = true, -- Auto-cleanup on exit
      },

      -- Connection settings
      sshfs_options = {
        reconnect = true, -- Auto-reconnect on connection drop
        ConnectTimeout = 5, -- SSH connection timeout
      },

      -- UI preferences
      ui = {
        local_picker = "telescope", -- Use Telescope for local file browsing
        remote_picker = "telescope", -- Use Telescope for remote searches
        prompt_format = "%s@%s:%s", -- Format: user@host:path
        confirm_mount = false, -- Skip mount confirmation
      },

      -- Lifecycle hooks
      handlers = {
        on_mount = {
          change_dir = true, -- Auto cd to mount point after mounting
          -- Uncomment to auto-run commands after mounting:
          -- find = true,        -- Auto-open file finder
          -- grep = true,        -- Auto-open grep search
          -- terminal = true,    -- Auto-open terminal
        },
        on_exit = {
          unmount_all = true, -- Unmount all on Neovim exit
          cleanup_mounts = false, -- Don't delete mount folders (they're reusable)
        },
      },

      -- Per-host default paths (optional)
      -- Uncomment and customize for your servers:
      -- host_paths = {
      --   ["your-server"] = "/var/www",
      --   ["another-server"] = { "/home/user/projects", "/var/log" }, -- Multiple paths
      -- },
    })
  end,

  keys = {
    { "<leader>sm", "<cmd>SSHConnect<cr>", desc = "SSH Mount" },
    { "<leader>su", "<cmd>SSHUnmount<cr>", desc = "SSH Unmount" },
    { "<leader>se", "<cmd>SSHExplore<cr>", desc = "SSH Explore" },
    { "<leader>sf", "<cmd>SSHFiles<cr>", desc = "SSH Browse Files" },
    { "<leader>sg", "<cmd>SSHGrep<cr>", desc = "SSH Grep" },
    { "<leader>sF", "<cmd>SSHLiveFind<cr>", desc = "SSH Live Find" },
    { "<leader>sG", "<cmd>SSHLiveGrep<cr>", desc = "SSH Live Grep" },
    { "<leader>st", "<cmd>SSHTerminal<cr>", desc = "SSH Terminal" },
    { "<leader>sd", "<cmd>SSHChangeDir<cr>", desc = "SSH Change Dir" },
    { "<leader>sc", "<cmd>SSHConfig<cr>", desc = "SSH Edit Config" },
    { "<leader>sr", "<cmd>SSHReload<cr>", desc = "SSH Reload Config" },
  },
}
