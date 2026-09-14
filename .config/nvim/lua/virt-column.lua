-- Subtle 80-column marker via extmarks.
-- Replaces lukas-reineke/virt-column.nvim, which still calls the deprecated
-- vim.validate{table} form (scheduled for removal in Nvim 1.0).

local ns = vim.api.nvim_create_namespace('virtcolumn')
local COLUMN = 80
local CHAR = '│'
local HL = 'VirtColumn'

local exclude_ft = {
  lspinfo = true,
  packer = true,
  checkhealth = true,
  help = true,
  man = true,
  TelescopePrompt = true,
  TelescopeResults = true,
}
local exclude_bt = {
  nofile = true,
  quickfix = true,
  terminal = true,
  prompt = true,
}

vim.api.nvim_set_hl(0, 'VirtColumn', { link = 'Whitespace', default = true })

vim.api.nvim_set_decoration_provider(ns, {
  on_win = function(_, win, buf, topline, botline)
    if not vim.api.nvim_buf_is_valid(buf) then
      return false
    end
    if exclude_ft[vim.bo[buf].filetype] or exclude_bt[vim.bo[buf].buftype] then
      pcall(vim.api.nvim_buf_clear_namespace, buf, ns, 0, -1)
      return false
    end

    local leftcol = vim.api.nvim_win_call(win, vim.fn.winsaveview).leftcol or 0
    pcall(vim.api.nvim_buf_clear_namespace, buf, ns, topline, botline)

    local i = topline
    while i <= botline do
      local width = vim.api.nvim_win_call(win, function()
        return vim.fn.virtcol { i, '$' } - 1
      end)
      if width < COLUMN then
        pcall(vim.api.nvim_buf_set_extmark, buf, ns, i - 1, 0, {
          virt_text = { { CHAR, HL } },
          virt_text_pos = 'overlay',
          hl_mode = 'combine',
          virt_text_win_col = COLUMN - 1 - leftcol,
          priority = 1,
        })
      end
      local fold_end = vim.api.nvim_win_call(win, function()
        return vim.fn.foldclosedend(i)
      end)
      if fold_end ~= -1 then
        i = fold_end
      end
      i = i + 1
    end
  end,
})
