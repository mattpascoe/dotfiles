-- Set up abbreviations
vim.cmd.abbrev('-...', '------------------------------------------------------')
vim.cmd.abbrev(
  'RuL',
  '----+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0'
)
vim.cmd.abbrev(
  'NuM',
  '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890'
)

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('i', 'ii', '<C-[>') -- Quick escape to normal mode TBD if useful
-- disabled for now to allow for forward movement repeats.  TBD
-- vim.keymap.set('n', ';', ':') -- map ; for cmd mode so no need for shift

-- Open a terminal
vim.keymap.set('n', '<leader>tt', ':terminal<cr>', { desc = '[T]erminal', noremap = true, silent = true })

-- Toggle paste and spell mode with status
vim.keymap.set('n', '<leader>tn', ':set number!<cr>', { desc = 'line [N]umbers', noremap = true, silent = true })
vim.keymap.set('n', '<leader>tp', ':set paste!<cr>', { desc = '[P]aste mode', noremap = true, silent = true })
vim.keymap.set('n', '<leader>ts', ':set spell!<cr>', { desc = '[S]pellcheck mode', noremap = true, silent = true })
--vim.api.nvim_set_hl(0, 'SpellBad', { ctermfg = 12, sp = 12, italic = true, undercurl = true })

-- NOTE: do I want any single character going into the * register unless I specifically want it?  TBD
-- dont store single letter deletes to the register
vim.keymap.set('n', 'x', '"_x', { noremap = true, silent = true })
vim.keymap.set('n', 'X', '"_x', { noremap = true, silent = true })

-- Reload the configuration file without restarting vim
vim.keymap.set('n', '<leader>R', '<cmd>source $MYVIMRC<CR>', { desc = 'VIM Configuration [R]eload' })

-- buffers
vim.keymap.set('n', '<leader>b', ':enew<cr>', { desc = 'Open a new [b]uffer', silent = true })
vim.keymap.set('n', '<leader>n', ':bn<cr>', { desc = '[N]ext buffer', silent = true })
vim.keymap.set('n', '<leader>p', ':bp<cr>', { desc = '[P]revious buffer', silent = true })
vim.keymap.set('n', '<leader>l', ':b#<cr>', { desc = '[L]ast active buffer', silent = true })
vim.keymap.set('n', '<leader>x', ':bd<cr>', { desc = 'Close buffer', silent = true })

-- Gitsigns show blame line
vim.keymap.set(
  'n',
  '<leader>cb',
  ':Gitsigns blame_line<cr>',
  { desc = '[C]ode git [b]lame line', noremap = true, silent = true }
)
vim.keymap.set(
  'n',
  '<leader>cB',
  ':Gitsigns blame<cr>',
  { desc = '[C]ode git [B]lame full', noremap = true, silent = true }
)

-- yank to clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { desc = '[Y]ank selection to clipboard' })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
