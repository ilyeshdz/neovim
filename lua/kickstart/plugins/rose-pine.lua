---@module 'lazy'
---@type LazySpec
return {
  { -- Rosé Pine colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'rose-pine/neovim',
    name = 'rose-pine',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      require('rose-pine').setup {
        styles = {
          bold = true,
          italic = true,
          transparency = false,
        },
        palette = {
          -- Darkened background/surface/overlay to match the terminal theme.
          main = {
            base = '#050301',
            surface = '#0d0b12',
            overlay = '#181526',
            highlight_low = '#0d0b12',
            highlight_med = '#181526',
            highlight_high = '#26233a',
          },
        },
      }

      -- Load the colorscheme here.
      vim.cmd.colorscheme 'rose-pine'
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et