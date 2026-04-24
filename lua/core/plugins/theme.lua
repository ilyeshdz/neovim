return {
	{ "rktjmp/lush.nvim", lazy = true },
	{
		"mcchrish/zenbones.nvim",
		lazy = false,
		priority = 1000,
		dependencies = { "rktjmp/lush.nvim" },
		config = function()
			vim.cmd.colorscheme("zenbones")
		end,
	},
}
