local group = vim.api.nvim_create_augroup("core.autocmds", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
	group = group,
	desc = "Highlight on yank",
	callback = function()
		vim.highlight.on_yank()
	end,
})
