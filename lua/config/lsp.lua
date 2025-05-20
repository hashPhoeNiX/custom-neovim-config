local servers = {}

local lspconfig = require('lspconfig')
if nixCats('neonixdev') then
  vim.api.nvim_create_autocmd(
    'FileType',
    {
      group = vim.api.nvim_create_augroup('nixCats-lazydev', { clear = true }),
      pattern = { 'lua' },
      callback = function(event)
        vim.cmd.packadd('lazydev.nvim')
        require('lazydev').setup({
          library = {
            { path = require('nixCats').nixCatsPath ..'/lua', words = { "nixCats" } },
          }
        })
      end
    }
  ) 
  servers.lua_ls = {
    settings = {
      Lua = {
        formatters = {
          ignoreComments = true,
        },
        signatureHelp = { enabled = true },
        diagnostics = {
          globals = { 'nixCats' },
          disable = { 'missing-fields' },
        },
      },
      telemetry = { enabled = false },
    },
    filetypes = { 'lua' },
  }

end
