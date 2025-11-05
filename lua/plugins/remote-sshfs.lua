return {
  "nosduco/remote-sshfs.nvim",
  dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  opts = {
    connections = {
      ssh_configs = {
        vim.fn.expand("$HOME") .. "/.ssh/config",
        "/etc/ssh/ssh_config",
      },
      ssh_known_hosts = vim.fn.expand("$HOME") .. "/.ssh/known_hosts",
    },
    mounts = {
      base_dir = vim.fn.expand("$HOME") .. "/.local/share/nvim/mounts",
      unmount_on_disconnect = true,
    },
    handlers = {
      on_connect = {
        change_dir = true,
      },
      on_disconnect = {
        clean_mount_folders = false,
      },
    },
  },
}
