return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("core.lsp").setup()
		end,
	},
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		opts = {
			ui = {
				icons = {
					package_installed = "+",
					package_pending = ">",
					package_uninstalled = "-",
				},
			},
		},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"williamboman/mason.nvim",
		},
		opts = function()
			return {
				ensure_installed = require("core.lsp").server_names(),
				automatic_enable = true,
			}
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = {
				"clang-format",
				"gopls",
				"gersemi",
				"neocmakelsp",
				"prettier",
				"pyright",
				"stylua",
				"typescript-language-server",
				"zls",
			},
		},
	},
}
