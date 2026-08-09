---@module 'lazy'
---@type LazySpec
return {
  {
    'mrcjkb/rustaceanvim',
    version = '^6',
    lazy = false,
    ft = { 'rust' },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    opts = {
      server = {
        default_settings = {
          ['rust-analyzer'] = {
            checkOnSave = {
              command = 'clippy',
            },
            inlayHints = {
              chainingHints = { enable = true },
              typeHints = { enable = true },
              parameterHints = { enable = true },
            },
          },
        },
      },
    },
  },
}
