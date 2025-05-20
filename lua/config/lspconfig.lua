-- inspired by: https://github.com/Lalit64/nvim/blob/main/lua/plugins/init.lua

local servers = {}
if nixCats("neonixdev") then
  -- NOTE: Lazydev will make your Lua LSP stronger for Neovim config
  -- NOTE: we are also using this as an opportunity to show you how to lazy load plugins!
  -- This plugin was added to the optionalPlugins section of the main flake.nix of this repo.
  -- Thus, it is not loaded and must be packadded.
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("nixCats-lazydev", { clear = true }),
    pattern = { "lua" },
    callback = function(event)
      -- NOTE: Use `:nixCats pawsible` to see the names of all plugins downloaded via Nix for packad.
      vim.cmd.packadd("lazydev.nvim")
      require("lazydev").setup({
        library = {
          --   -- See the configuration section for more details
          --   -- Load luvit types when the `vim.uv` word is found
          --   -- { path = "luvit-meta/library", words = { "vim%.uv" } },
          -- adds type hints for nixCats global
          { path = require("nixCats").nixCatsPath .. "/lua", words = { "nixCats" } },
        },
      })
    end,
  })
  -- NOTE: use BirdeeHub/lze to manage the autocommands for you if the above seems tedious. Or, use the wrapper for lazy.nvim included in the luaUtils template.
  -- NOTE: AFTER DIRECTORIES WILL NOT BE SOURCED BY PACKADD!!!!!
  -- this must be done by you manually if,
  -- for example, you wanted to lazy load nvim-cmp sources

  servers.lua_ls = {
    settings = {
      Lua = {
        formatters = {
          ignoreComments = true,
        },
        signatureHelp = { enabled = true },
        diagnostics = {
          globals = { "nixCats" },
          disable = { "missing-fields" },
        },
      },
      telemetry = { enabled = false },
    },
    filetypes = { "lua" },
  }
  if require("nixCatsUtils").isNixCats then
    -- nixd requires some configuration.
    -- luckily, the nixCats plugin is here to pass whatever we need!
    -- we passed this in via the `extra` table in our packageDefinitions
    -- for additional configuration options, refer to:
    -- https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
    servers.nixd = {
      settings = {
        nixd = {
          nixpkgs = {
            -- in the extras set of your package definition:
            -- nixdExtras.nixpkgs = ''import ${pkgs.path} {}''
            expr = nixCats.extra("nixdExtras.nixpkgs") or [[import <nixpkgs> {}]],
          },
          options = {
            -- If you integrated with your system flake,
            -- you should use inputs.self as the path to your system flake
            -- that way it will ALWAYS work, regardless
            -- of where your config actually was.
            nixos = {
              -- nixdExtras.nixos_options = ''(builtins.getFlake "path:${builtins.toString inputs.self.outPath}").nixosConfigurations.configname.options''
              expr = nixCats.extra("nixdExtras.nixos_options"),
            },
            -- If you have your config as a separate flake, inputs.self would be referring to the wrong flake.
            -- You can override the correct one into your package definition on import in your main configuration,
            -- or just put an absolute path to where it usually is and accept the impurity.
            ["home-manager"] = {
              -- nixdExtras.home_manager_options = ''(builtins.getFlake "path:${builtins.toString inputs.self.outPath}").homeConfigurations.configname.options''
              expr = nixCats.extra("nixdExtras.home_manager_options"),
            },
          },
          formatting = {
            command = { "nixfmt" },
          },
          diagnostic = {
            suppress = {
              "sema-escaping-with",
            },
          },
        },
      },
    }
  else
    servers.rnix = {}
    servers.nil_ls = {}
  end
end

if not require("nixCatsUtils").isNixCats and nixCats("lspDebugMode") then
  vim.lsp.set_log_level("debug")
end

-- This is this flake's version of what kickstarter has set up for mason handlers.
-- This is a convenience function that calls lspconfig on the LSPs we downloaded via nix
-- This will not download your LSP --- Nix does that.

--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--  All of them are listed in https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
--  You may do the same thing with cmd

-- servers.clangd = {}
-- servers.gopls = {}
-- servers.pyright = {}
servers.basedpyright = {
  settings = {
    basedpyright = {
      -- Using Ruff's import organizer
      disableOrganizeImports = true,
      analysis = {
        diagnosticMode = "openFilesOnly",
        inlayHints = {
          callArgumentNames = true,
        },
      },
    },
    python = {
      analysis = {
        -- Ignore all files for analysis to exclusively use Ruff for linting
        ignore = { "*" },
      },
    },
  },
}

-- Ruff config
local on_attach = function(client, bufnr)
  if client.name == "ruff_lsp" then
    -- Disable hover in favor of Pyright
    client.server_capabilities.hoverProvider = false
  end
end
servers.ruff_lsp = {
  on_attach = on_attach,
}
-- servers.rust_analyzer = {}
-- servers.tsserver = {}
-- servers.html = { filetypes = { 'html', 'twig', 'hbs'} }

-- If you were to comment out this autocommand
-- and instead pass the on attach function directly to
-- nvim-lspconfig, it would do the same thing.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("nixCats-lsp-attach", { clear = true }),
  callback = function(event)
    require("caps-on_attach").on_attach(vim.lsp.get_client_by_id(event.data.client_id), event.buf)
  end,
})
if require("nixCatsUtils").isNixCats then
  for server_name, cfg in pairs(servers) do
    require("lspconfig")[server_name].setup({
      capabilities = require("caps-on_attach").get_capabilities(server_name),
      -- this line is interchangeable with the above LspAttach autocommand
      -- on_attach = require('caps-on_attach').on_attach,
      settings = (cfg or {}).settings,
      filetypes = (cfg or {}).filetypes,
      cmd = (cfg or {}).cmd,
      root_pattern = (cfg or {}).root_pattern,
    })
  end
else
  require("mason").setup()
  local mason_lspconfig = require("mason-lspconfig")
  mason_lspconfig.setup({
    ensure_installed = vim.tbl_keys(servers),
  })
  mason_lspconfig.setup_handlers({
    function(server_name)
      require("lspconfig")[server_name].setup({
        capabilities = require("caps-on_attach").get_capabilities(server_name),
        -- this line is interchangeable with the above LspAttach autocommand
        -- on_attach = require('caps-on_attach').on_attach,
        settings = (servers[server_name] or {}).settings,
        filetypes = (servers[server_name] or {}).filetypes,
      })
    end,
  })
end
