return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    ---@type table<string, snacks.win.Config>
    styles = {
      terminal = {
        bo = {
          filetype = "snacks_terminal",
        },
        wo = {},
        keys = {
          q = "hide",
          gf = function(self)
            local f = vim.fn.findfile(vim.fn.expand("<cfile>"), "**")
            if f == "" then
              Snacks.notify.warn("No file under cursor")
            else
              self:hide()
              vim.schedule(function()
                vim.cmd("e " .. f)
              end)
            end
          end,
          term_normal = {
            "<esc>",
            function(self)
              self.esc_timer = self.esc_timer or (vim.uv or vim.loop).new_timer()
              if self.esc_timer:is_active() then
                self.esc_timer:stop()
                vim.cmd("stopinsert")
              else
                self.esc_timer:start(200, 0, function() end)
                return "<esc>"
              end
            end,
            mode = "t",
            expr = true,
            desc = "Double escape to normal mode",
          },
        },
      },
      zoom_indicator = {
        text = "▍ zoom  󰊓  ",
        minimal = true,
        enter = false,
        focusable = false,
        height = 1,
        row = 0,
        col = -1,
        backdrop = false,
      }
    },
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = true },
    dashboard = { enabled = true },
    explorer = {
      enabled = true,
      replace_netrw = true, -- Replace netrw with snacks explorer
      ---@type snacks.explorer.Config
      ---@diagnostic disable-next-line: missing-fields
      opts = {
        win = {
          style = "explorer",
        },
      },
    },
    indent = {
      enabled = true,
      indent = {
        enabled = true,
        only_scope = false,         -- show all indents, not just scope
        only_current = false,       -- show indents for all lines, not just current
        hl = "IndentBlanklineChar", -- dimmer highlight for regular indents
      },
      scope = {
        enabled = true,                    -- highlight current scope
        hl = "IndentBlanklineContextChar", -- brighter highlight for current scope
      },
      chunk = {
        enabled = true, -- visualize code chunks
      },
    },
    input = { enabled = true },
    gh = {
      -- your gh configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    picker = {
      enabled = true,
      hidden = true,
      ignored = true,
      sources = {
        gh_issue = {
          -- your gh_issue picker configuration comes here
          -- or leave it empty to use the default settings
        },
        gh_pr = {
          -- your gh_pr picker configuration comes here
          -- or leave it empty to use the default settings
        }
        --   files = {
        --     hidden = true,
        --     ignored = true,
        --     -- exclude = {
        --     -- "**/.git/*",
        --     --},
        --   },
      },
    },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    terminal = {
      win = { style = "terminal" },
      enabled = true
    },
    zen = {
      ---@class snacks.zen.Config
      -- You can add any `Snacks.toggle` id here.
      -- Toggle state is restored when the window is closed.
      -- Toggle config options are NOT merged.
      ---@type table<string, boolean>
      enabled = true,
      toggles = {
        dim = true,
        git_signs = false,
        mini_diff_signs = false,
        -- diagnostics = false,
        -- inlay_hints = false,
      },
      show = {
        statusline = false, -- can only be shown when using the global statusline
        tabline = false,
      },
      ---@type snacks.win.Config
      win = { style = "zen" },
      --- Callback when the window is opened.
      ---@param win snacks.win
      on_open = function(win) end,
      --- Callback when the window is closed.
      ---@param win snacks.win
      on_close = function(win) end,
      --- Options for the `Snacks.zen.zoom()`
      ---@type snacks.zen.Config
      zoom = {
        toggles = {},
        show = { statusline = true, tabline = true },
        win = {
          backdrop = false,
          width = 0, -- full width
        },
      },
    }
  },
  config = function(_, opts)
    require("snacks").setup(opts)

    -- Set up dimmer colors for non-focused indent lines
    vim.api.nvim_set_hl(0, "IndentBlanklineChar", { fg = "#2a2e36", nocombine = true })
    vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", { fg = "#4a5057", nocombine = true })
  end,
  keys = {
    -- Top Pickers & Explorer
    { "<leader><space>", function() Snacks.picker.smart() end,                     desc = "Smart Find Files" },
    { "<leader>,",       function() Snacks.picker.buffers() end,                   desc = "Buffers" },
    { "<leader>/",       function() Snacks.picker.grep() end,                      desc = "Grep" },
    { "<leader>:",       function() Snacks.picker.command_history() end,           desc = "Command History" },
    { "<leader>n",       function() Snacks.picker.notifications() end,             desc = "Notification History" },
    { "<leader>e",       function() Snacks.explorer() end,                         desc = "File Explorer" },

    -- LSP: Disabled in favor of native LSP from lsp-keymaps.lua for better dbt-language-server support
    -- { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
    -- { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
    -- { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
    -- { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
    -- { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
    -- { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
    -- { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
    { "<leader>ft",      function() Snacks.terminal.toggle() end,                  desc = "Toggle Terminal" },
    { "<leader>fp",      function() Snacks.picker.projects() end,                  desc = "Projects" },
    { "<leader>fr",      function() Snacks.picker.recent() end,                    desc = "Recent" },
    { "<leader>wm",      function() Snacks.zen.zoom() end,                         desc = "Toggle Zoom" },

    -- GitHub
    { "<leader>gi",      function() Snacks.picker.gh_issue() end,                  desc = "GitHub Issues (open)" },
    { "<leader>gI",      function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)" },
    { "<leader>gp",      function() Snacks.picker.gh_pr() end,                     desc = "GitHub Pull Requests (open)" },
    { "<leader>gP",      function() Snacks.picker.gh_pr({ state = "all" }) end,    desc = "GitHub Pull Requests (all)" },
  },
}
