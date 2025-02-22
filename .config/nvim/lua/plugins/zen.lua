return {
  {
    -- TODO: Consider zen-mode plugin as well, it would wrap/include this
    -- This will highlight a section of code to make it stand out. Uses telescope
    'folke/twilight.nvim',
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    config = function()
      vim.keymap.set(
        'n',
        '<leader>tz',
        ':Twilight<CR>',
        { desc = '[Z]en mode (twilight)', noremap = true, silent = true }
      )
    end,
  },
}
