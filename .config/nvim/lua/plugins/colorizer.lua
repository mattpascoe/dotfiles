return {
  -- Show actual colors for references
  -- Some example colors to convert with <leader>tc:
  -- #FF0000
  -- #00FF00
  -- TODO: there seems to be some sort of problem Clearing and toggling back off
  {
    'chrisbra/Colorizer',
    init = function()
      vim.keymap.set('n', '<leader>tc', ':ColorToggle<cr>', { desc = '[C]olor Preview' })
      -- sets the color at the end of the line
      -- Seems to have a bug that toggleing just adds another block
      vim.g.colorizer_use_virtual_text = 1
      vim.g.colorizer_auto_filetype = 'css,html'
    end,
  },
}
