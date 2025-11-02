--- LSP configuration for Neovim

-- Register LSP server configurations
local lsp_servers = {
  "lua_ls",
  "nixd",
  "dbt",
}

-- Register each LSP server with vim.lsp.config()
for _, server_name in ipairs(lsp_servers) do
  local ok, config = pcall(require, "lsp." .. server_name)
  if ok then
    -- Register the server configuration
    vim.lsp.config(server_name, config)
  end
end

-- Enable all registered LSP servers
vim.lsp.enable(lsp_servers)

--- This file sets up the LSP client, key mappings, and autocommands for LSP features.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local bufnr = ev.buf

    -- Enable completion for this buffer
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = false })
    end

    -- Override Snacks' keybindings with native LSP for dbt
    -- Go to definition (override Snacks' picker)
    if client:supports_method('textDocument/definition') then
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr, desc = 'LSP: Go to Definition', noremap = true })
    end

    -- Hover documentation (keep using native LSP)
    if client:supports_method('textDocument/hover') then
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, desc = 'LSP: Hover Documentation', noremap = true })
    end
  end,
})
-- This is copied straight from blink
-- https://cmp.saghen.dev/installation#merging-lsp-capabilities
if nixCats("neonixdev") then
  local capabilities = {
    textDocument = {
      foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      },
    },
  }
  capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
end

vim.diagnostic.enable(true)
vim.diagnostic.config({
  -- signs = true,
  virtual_text = true,
})
