---@module 'lazy'
---@type LazySpec
return {
  { -- A collection of contrast-based colorschemes.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'zenbones-theme/zenbones.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    dependencies = 'rktjmp/lush.nvim', -- Required dependency; enables further config
    config = function()
      -- Make the background darker than the default ('stark' is the darkest).
      -- Options: 'default', 'dim', 'bright', 'bright', 'stark', 'warm'
      vim.g.zenbones_darkness = 'stark'
      vim.g.zenbones_darken_comments = 60

      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'neobones', 'rosebones', 'forestbones', or 'tokyobones'.
      vim.cmd.colorscheme 'zenbones'
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et