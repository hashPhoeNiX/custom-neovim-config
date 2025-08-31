local map = function(keys, func, desc, mode)
  mode = mode or 'n'
  vim.keymap.set(mode, keys, func, { desc = 'LSP: ' .. desc })
end

vim.keymap.set('n', '<leader>ud', function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = 'Toggle Diagnostics' })

map('<leader>cd', function()
  vim.diagnostic.open_float()
end, 'Goto Definition')

map('gd', function()
  vim.lsp.buf.definition()
end, 'Goto Definition')

map('<leader>gI', function()
  vim.lsp.buf.implementation()
end, 'Goto Implementation')

map('gy', function()
  vim.lsp.buf.type_definition()
end, 'Goto Type Definition')

map('gK', function()
  vim.lsp.buf.signature_help()
end, 'Signature Help')

map('<leader>uh', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled)
end, 'Toggle Inlay Hints')
