local M = {}

local servers = {
	clangd = {
		cmd = { "clangd", "--background-index", "--clang-tidy" },
	},
	neocmake = {},
}

local server_binaries = {
	clangd = "clangd",
	neocmake = "neocmakelsp",
}

local function lsp_capabilities()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	local ok, blink = pcall(require, "blink.cmp")

	if ok then
		return blink.get_lsp_capabilities(capabilities)
	end

	return capabilities
end

local function server_is_available(server)
	local binary = server_binaries[server]
	if not binary then
		return true
	end

	local mason_binary = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", binary)
	return vim.fn.executable(binary) == 1 or vim.fn.executable(mason_binary) == 1
end

local function set_lsp_keymaps(event)
	local bufnr = event.buf
	local opts = { buffer = bufnr, silent = true }
	local map = vim.keymap.set

	map("n", "la", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
	map("n", "lr", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
	map("n", "ld", function()
		vim.diagnostic.open_float(0, { border = "rounded", focusable = false, scope = "line" })
	end, vim.tbl_extend("force", opts, { desc = "Line diagnostics" }))
	map("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
	map("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
	map("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
	map("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Go to references" }))
	map("n", "gt", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))
	map("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
	map("n", "<C-k>", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))
	map("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
	map("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
end

function M.setup()
	local group = vim.api.nvim_create_augroup("core.lsp", { clear = true })

	vim.diagnostic.config({
		severity_sort = true,
		float = {
			border = "rounded",
			source = "if_many",
		},
		signs = true,
		underline = true,
		virtual_lines = {
			current_line = true,
		},
		virtual_text = false,
	})

	vim.api.nvim_create_autocmd("LspAttach", {
		group = group,
		callback = function(event)
			set_lsp_keymaps(event)
		end,
	})

	local capabilities = lsp_capabilities()

	for server, config in pairs(servers) do
		vim.lsp.config(
			server,
			vim.tbl_deep_extend("force", {
				capabilities = capabilities,
			}, config)
		)

		if server_is_available(server) then
			vim.lsp.enable(server)
		end
	end
end

function M.server_names()
	return vim.tbl_keys(servers)
end

function M.missing_servers()
	return vim.tbl_filter(function(server)
		return not server_is_available(server)
	end, vim.tbl_keys(servers))
end

return M
