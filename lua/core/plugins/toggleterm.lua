return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				open_mapping = false,
				shade_filetypes = {},
				shade_terminals = false,
				shell = vim.o.shell,
			})

			local Terminal = require("toggleterm.terminal")

			local function toggle_term(size, direction, name)
				local term = Terminal:new({
					size = size,
					direction = direction,
					name = name,
				})
				term:toggle()
			end

			vim.keymap.set("n", "<leader>th", function()
				toggle_term(10, "horizontal", "HTerm")
			end, { desc = "Horizontal terminal" })

			vim.keymap.set("n", "<leader>tf", function()
				toggle_term(nil, "float", "FTerm")
			end, { desc = "Floating terminal" })

			vim.keymap.set("n", "<leader>tv", function()
				toggle_term(vim.o.columns * 0.4, "vertical", "VTerm")
			end, { desc = "Vertical terminal" })
		end,
	},
}