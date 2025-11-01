-- dbt Language Server configuration (native Neovim LSP)
-- No dependencies: pure vim.lsp, no mason, no nvim-lspconfig

return {
  name = 'dbt',
  cmd = { 'dbt-language-server' },
  root_markers = { 'dbt_project.yml' },
  filetypes = { 'sql', 'yaml' },

  -- Optional capabilities
  capabilities = vim.lsp.protocol.make_client_capabilities(),

  -- Document options
  settings = {},
}
