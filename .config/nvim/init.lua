-- For now, I'm going to source the .vimrc first. My goal here is to allow a common
-- vim configuraiton that will work under both as close to the same as possible.
-- I run on many remote machines where neovim wont exist so this feels the best to keep
-- things as close to the same as possible. TBD
vim.cmd.source("~/.vimrc")

-- I tried lazy.nvim but it fought with vim-plug from my .vimrc
-- This will load the following plugins only in nvim. If you run PlugClean on
-- the vim side it will try and delete these. Beware.
vim.cmd("Plug 'nvim-lua/plenary.nvim'")
vim.cmd("Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.5' }")
--vim.cmd("Plug 'MasterTemple/bible.nvim'")
vim.cmd('call plug#end()')




-- Trying to get the bible plugin to work, it requires lsqlite3.. from luarocks?
--	keys = {
--		{"<leader>es", '<cmd>lua require("telescope").extensions.bible.bible({isReferenceOnly = false, isMultiSelect = false})<CR>', desc = "Search by verse content" },
--		{"<leader>er", '<cmd>lua require("telescope").extensions.bible.bible({isReferenceOnly = true, isMultiSelect = false})<CR>', desc = "Search by verse reference" },
--		{"<leader>ems", '<cmd>lua require("telescope").extensions.bible.bible({isReferenceOnly = false, isMultiSelect = true})<CR>', desc = "Search by verse content (multi-select)" },
--		{"<leader>emr", '<cmd>lua require("telescope").extensions.bible.bible({isReferenceOnly = true, isMultiSelect = true})<CR>', desc = "Search by verse reference (multi-select)" },
--	}
--vim.keymap.set('n', '<leader>es', require("telescope").extensions.bible.bible({isReferenceOnly = false, isMultiSelect = false}))
--vim.keymap.set('n', '<leader>er', require("telescope").extensions.bible.bible({isReferenceOnly = true, isMultiSelect = false}))

-- Configure Telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})


