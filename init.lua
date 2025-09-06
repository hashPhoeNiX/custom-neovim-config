require('nixCatsUtils').setup {
  non_nix_value = true,
}

require("config.lsp")
require("config.lsp-keymaps")
require("config.vim-options")
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
  dev = {
    path = "~/Projects",
    patterns = {},   -- For example {"folke"}
    fallback = true, -- Fallback to git when local plugin doesn't exist
  }
}
-- plugins = require("plugins")

require('nixCatsUtils.lazyCat').setup(
  nixCats.pawsible { 'allPlugins', 'start', 'lazy.nvim' },
  -- "plugins", --this works too
  {
    { import = "plugins" },
    { import = "plugins.data-tools" },
  },
  lazyOptions
)
