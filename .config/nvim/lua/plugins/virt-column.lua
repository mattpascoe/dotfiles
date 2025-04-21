-- https://github.com/lukas-reineke/virt-column.nvim
--
-- Using this to draw a more subtle highlight for the colorcolumn
-- It works well on my current crappy TV monitor.  I notice on the native
-- macbook display that the highlight is hardly visible.

return {
  'lukas-reineke/virt-column.nvim',
  opts = {
    virtcolumn = '80',
    highlight = 'VirtColumn',
  },
}
