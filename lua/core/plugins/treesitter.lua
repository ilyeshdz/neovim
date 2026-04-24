return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		main = "nvim-treesitter",
		opts = {
			ensure_installed = {
				"c",
				"cmake",
				"cpp",
				"lua",
				"vim",
				"vimdoc",
			},
			auto_install = false,
			highlight = {
				enable = true,
			},
			indent = {
				enable = true,
			},
		},
	},
}
