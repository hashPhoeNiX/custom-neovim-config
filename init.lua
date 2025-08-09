require('nixCatsUtils').setup {
  non_nix_value = true,
}
-- NOTE: You might want to move the lazy-lock.json file
local function getlockfilepath()
  if require('nixCatsUtils').isNixCats and type(nixCats.settings.unwrappedCfgPath) == 'string' then
    return nixCats.settings.unwrappedCfgPath .. '/lazy-lock.json'
  else
    return vim.fn.stdpath 'config' .. '/lazy-lock.json'
  end
end

local lazyOptions = {
  lockfile = getlockfilepath(),
}
require("config.lsp")
require("config.vim-options")
-- plugins = require("plugins")

require('nixCatsUtils.lazyCat').setup(
  nixCats.pawsible { 'allPlugins', 'start', 'lazy.nvim' },
  -- "plugins", --this works too
  {import = "plugins"},
  lazyOptions
)
