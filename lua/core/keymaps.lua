local map = vim.keymap.set

map("n", "<leader>q", vim.diagnostic.setloclist, { silent = true, desc = "Diagnostics list" })

local sections = {
	{
		title = "LSP",
		entries = {
			"<leader>la    Code action",
			"<leader>lr    Rename symbol",
			"gd           Go to definition",
			"gD           Go to declaration",
			"gi           Go to implementation",
			"gr           Go to references",
			"gt           Go to type definition",
			"K             Hover documentation",
			"<C-k>         Signature help",
			"[d / ]d       Previous / next diagnostic",
		},
	},
	{
		title = "Search",
		entries = {
			"<leader>ff Find files",
			"<leader>fg Live grep",
			"<leader>fb Buffers",
			"<leader>fh Help tags",
			"<leader>fc Colorschemes",
			"<leader>fr Resume search",
		},
	},
	{
		title = "Tools",
		entries = {
			"<leader>e  Toggle file tree",
			"<leader>f  Format buffer",
			"<leader>gg LazyGit",
			"<leader>th Horizontal terminal",
			"<leader>tf Floating terminal",
			"<leader>tv Vertical terminal",
			"<leader>H  Show this help",
		},
	},
}

local function show_keybindings()
	local lines = {}

	for index, section in ipairs(sections) do
		table.insert(lines, section.title)
		table.insert(lines, string.rep("-", #section.title))

		for _, entry in ipairs(section.entries) do
			table.insert(lines, entry)
		end

		if index < #sections then
			table.insert(lines, "")
		end
	end

	local width = 0
	for _, line in ipairs(lines) do
		width = math.max(width, #line)
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].filetype = "help"
	vim.bo[buf].modifiable = false

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width + 4,
		height = #lines,
		row = 1,
		col = math.max(vim.o.columns - width - 6, 0),
		style = "minimal",
		border = "rounded",
		title = " Keybindings ",
		title_pos = "center",
	})

	vim.wo[win].wrap = false
	vim.wo[win].cursorline = false
end

map("n", "<leader>H", show_keybindings, { silent = true, desc = "Show keybindings help" })
