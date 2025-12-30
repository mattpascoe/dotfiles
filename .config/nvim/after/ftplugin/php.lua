local set = vim.opt_local

-- Attempting to define some standard PHP settings
-- Just know that nvim-sluth is probably going to make its own updates
set.shiftwidth = 4
set.tabstop = 4
set.smartindent = false
set.autoindent = true
-- set.cinoptions = vim.opt.cinoptions:get() .. ',+s'

-- For PHP files only, lets ensure blank lines are indented with spaces
-- This is how Brandon likes the format so its like PHPStorm.
-- Set buffer-local mappings (buffer = 0 or true refers to the current file)
local opts = { noremap = true, silent = true, buffer = true }

-- Insert mode: Enter key keeps the indent
vim.keymap.set('i', '<CR>', '<C-o>o=<BS>', opts)

-- Normal mode: 'o' and 'O' keep the indent
vim.keymap.set('n', 'o', 'ox<BS>', opts)
vim.keymap.set('n', 'O', 'Ox<BS>', opts)
