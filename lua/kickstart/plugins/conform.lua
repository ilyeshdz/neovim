---@module 'lazy'
---@type LazySpec

-- Resolve the formatter at runtime based on the project's runtime: Deno
-- projects use `deno fmt`, Bun/Node projects use Prettier.
---@param bufnr integer
---@return string[]?
local function js_formatters(bufnr)
  local is_deno = vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc', 'deno.lock' }) ~= nil
  if is_deno then
    return { 'deno_fmt' }
  else
    return { 'prettierd', 'prettier', stop_after_first = true }
  end
end

return {
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>mf',
        function() require('conform').format { async = true } end,
        mode = '',
        desc = '[M]ake [F]ormat buffer',
      },
    },
    ---@module 'conform'
    ---@type conform.setupOpts
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- You can specify filetypes to autoformat on save here:
        local enabled_filetypes = {
          -- lua = true,
          -- python = true,
        }
        if enabled_filetypes[vim.bo[bufnr].filetype] then
          return { timeout_ms = 500 }
        else
          return nil
        end
      end,
      default_format_opts = {
        lsp_format = 'fallback', -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
      },
      -- You can also specify external formatters in here.
      formatters_by_ft = {
        -- Deno & Bun both use TypeScript/JavaScript, so we pick the formatter
        -- based on which runtime the project uses (detected by root files) rather
        -- than by filetype alone.
        typescript = js_formatters,
        typescriptreact = js_formatters,
        javascript = js_formatters,
        javascriptreact = js_formatters,
      },
      formatters = {
        deno_fmt = {
          command = 'deno',
          args = { 'fmt', '-' },
          stdin = true,
        },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
