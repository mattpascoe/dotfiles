return {
  {
    -- Highlight chunk of code, this will show indentations as well
    'shellRaining/hlchunk.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('hlchunk').setup({
        chunk = {
          enable = false,
          delay = 0,
        },
        indent = {
          enable = true,
          style = '#1c1f21',
        },
        line_num = {
          enable = true,
          style = '#806d9c',
        },
        blank = {
          enable = false,
          chars = {
            ' ',
          },
          style = {
            { bg = '#434437' },
            { bg = '#2f4440' },
            { bg = '#433054' },
            { bg = '#284251' },
          },
        },
      })
    end,
  },
}
