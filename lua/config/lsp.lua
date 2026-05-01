--- LSP configuration for Neovim
--
-- Neovim 0.12: lsp/*.lua files at the runtimepath root are auto-discovered
-- lazily (loaded when a matching filetype buffer opens). No require() needed.
-- vim.lsp.enable() below registers which servers to auto-start; their configs
-- are pulled from lsp/<name>.lua on first use.

local lsp_servers = {
  "lua_ls",
  "nixd",
  "dbt",
  -- DevOps LSPs
  "docker",
  "docker-compose",
  "terraform",
  "yaml",
}

-- Enable all servers — Neovim 0.12 auto-discovers their configs from lsp/*.lua
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
