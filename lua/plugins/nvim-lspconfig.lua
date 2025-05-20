return -- lsp for completion and diagnostics
{
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{
			"folke/lazydev.nvim",
			ft = "lua",
			--opts = require("plugins.configs.lazydev"),
		},
	},
	config = function()
		require("lspconfig")
	end,
}
