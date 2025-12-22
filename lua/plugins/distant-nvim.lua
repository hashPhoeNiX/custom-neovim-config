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

    -- Helper function to resolve SSH config aliases
    local function resolve_ssh_host(input)
      -- If already a full URL, return as-is
      if input:match("^ssh://") then
        return input
      end

      -- If it looks like user@host:port, prepend ssh://
      if input:match("@") then
        return "ssh://" .. input
      end

      -- Otherwise, try to resolve as SSH config alias
      local handle = io.popen("ssh -G " .. vim.fn.shellescape(input) .. " 2>/dev/null")
      if not handle then
        vim.notify("Failed to resolve SSH config for: " .. input, vim.log.levels.ERROR)
        return nil
      end

      local result = handle:read("*a")
      handle:close()

      if result == "" then
        vim.notify("No SSH config found for: " .. input, vim.log.levels.ERROR)
        return nil
      end

      -- Parse ssh -G output
      local hostname = result:match("\nhostname%s+([^\n]+)")
      local port = result:match("\nport%s+([^\n]+)")
      local user = result:match("\nuser%s+([^\n]+)")

      if not hostname then
        vim.notify("Could not resolve hostname for: " .. input, vim.log.levels.ERROR)
        return nil
      end

      -- Build the distant URL
      local url = "ssh://"
      if user then
        url = url .. user .. "@"
      end
      url = url .. hostname
      if port and port ~= "22" then
        url = url .. ":" .. port
      end

      return url
    end

    -- Connection management (using <leader>r for "remote")
    map("n", "<leader>rl", function()
      vim.ui.input({ prompt = "Launch remote (user@host:port or SSH alias): " }, function(input)
        if input and input ~= "" then
          local destination = resolve_ssh_host(input)
          if destination then
            -- Execute the command with error handling
            local ok, err = pcall(vim.cmd, "DistantLaunch " .. destination)
            if not ok then
              vim.notify("Failed to launch: " .. tostring(err), vim.log.levels.ERROR)
            end
          end
        end
      end)
    end, vim.tbl_extend("force", opts, { desc = "Remote Launch" }))
    map("n", "<leader>rc", function()
      vim.ui.input({ prompt = "Connect to remote (user@host:port or SSH alias): " }, function(input)
        if input and input ~= "" then
          local destination = resolve_ssh_host(input)
          if destination then
            vim.notify("Connecting: " .. destination, vim.log.levels.INFO)
            vim.cmd("DistantConnect " .. destination)
          end
        end
      end)
    end, vim.tbl_extend("force", opts, { desc = "Remote Connect" }))
    map("n", "<leader>rd", "<cmd>DistantDisconnect<cr>", vim.tbl_extend("force", opts, { desc = "Remote Disconnect" }))

    -- File operations
    map("n", "<leader>rf", "<cmd>DistantOpen<cr>", vim.tbl_extend("force", opts, { desc = "Remote Open File" }))
    map("n", "<leader>re", function()
      -- Use DistantOpen with a browser-style interface
      -- This just delegates to DistantOpen which should show the file browser
      vim.cmd("DistantOpen")
    end, vim.tbl_extend("force", opts, { desc = "Remote Explore Directory" }))

    -- Directory operations
    map("n", "<leader>rm", "<cmd>DistantMkdir<cr>", vim.tbl_extend("force", opts, { desc = "Remote Make Directory" }))

    -- Shell
    map("n", "<leader>rt", "<cmd>DistantShell<cr>", vim.tbl_extend("force", opts, { desc = "Remote Shell" }))

    -- System info
    map("n", "<leader>ri", "<cmd>DistantClientVersion<cr>", vim.tbl_extend("force", opts, { desc = "Remote Info" }))
  end,
}
