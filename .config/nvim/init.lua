--[[

Initial startingpoint was Kickstart.nvim
https://github.com/nvim-lua/kickstart.nvim

:help lua-guide (or HTML version): https://neovim.io/doc/user/lua-guide.html

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.
--]]

-- TODO: look at the flash plugin. its like a quick search/navigation thing
-- TODO: look at noice but have it use mini as the notification method. this gives command popup in center with simple alerts via mini
-- TODO: Harper is like grammerly. its done as an LSP.
-- TODO: check out the render-markdown plugin.  linkarzu on youtube has a video on it to watch too. I have it now.. needs more config.. look at his transparent colors
--        Also his folds are handy.. need keymaps for it and to actually auto fold markdown?  I think he has a vid on it
-- TODO: snacks picker.. is it useful vs telescope? linkarzu also has a video on it.
--        there is an image viewer in snacks too
-- linkarzu has a vide where I found a lot of these plugins to try https://www.youtube.com/watch?v=08AYe8cMffI

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-------------------------------------------------------------------------------
--                           Folding section
-------------------------------------------------------------------------------

-- Startout unfolded
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

-- Checks each line to see if it matches a markdown heading (#, ##, etc.):
-- It’s called implicitly by Neovim’s folding engine by vim.opt_local.foldexpr
function _G.markdown_foldexpr()
  local lnum = vim.v.lnum
  local line = vim.fn.getline(lnum)
  local heading = line:match('^(#+)%s')
  if heading then
    local level = #heading
    if level == 1 then
      -- Special handling for H1
      if lnum == 1 then
        return '>1'
      else
        local frontmatter_end = vim.b.frontmatter_end
        if frontmatter_end and (lnum == frontmatter_end + 1) then
          return '>1'
        end
      end
    elseif level >= 2 and level <= 6 then
      -- Regular handling for H2-H6
      return '>' .. level
    end
  end
  return '='
end

local function set_markdown_folding()
  vim.opt_local.foldmethod = 'expr'
  -- vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  vim.opt_local.foldexpr = 'v:lua.markdown_foldexpr()'
  -- Start with mostly folded on markdown
  vim.opt_local.foldlevel = 1
  vim.opt_local.foldtext = ''
  -- vim.opt_local.foldcolumn = '0'
  -- remove the empty dots in the fold
  vim.opt_local.fillchars:append({ fold = ' ' })

  -- vim.opt_local.foldtext = 'v:lua.fold_func()'

  -- Detect frontmatter closing line
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local found_first = false
  local frontmatter_end = nil
  for i, line in ipairs(lines) do
    if line == '---' then
      if not found_first then
        found_first = true
      else
        frontmatter_end = i
        break
      end
    end
  end
  vim.b.frontmatter_end = frontmatter_end
end

-- function _G.fold_func()
--   local line_count = vim.v.foldend - vim.v.foldstart + 1
--   local first_line = vim.fn.getline(vim.v.foldstart)
--   local indicator = '> '
--   local count_text = string.format(' [%d lines]', line_count)
--
--   -- Get window width
--   local win_width = vim.api.nvim_win_get_width(0)
--
--   -- Truncate first_line if it's too long
--   local max_first_line_len = win_width - #indicator - #count_text - 1
--   if #first_line > max_first_line_len then
--     first_line = first_line:sub(1, max_first_line_len - 9) .. '...'
--   end
--
--   -- Build the full line and pad spaces between text and count
--   local padding = win_width - #indicator - #first_line - #count_text
--   local pad = string.rep(' ', math.max(padding, 1))
--
--   -- return string.format('%s%s%s%s', indicator, first_line, pad, count_text)
--   return string.format('%s%s', first_line, count_text)
-- end

-- Use autocommand to apply only to markdown files
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'vimwiki', 'markdown' },
  callback = set_markdown_folding,
})

-- Function to fold all headings of a specific level
local function fold_headings_of_level(level)
  -- Move to the top of the file without adding to jumplist
  vim.cmd('keepjumps normal! gg')
  -- Get the total number of lines
  local total_lines = vim.fn.line('$')
  for line = 1, total_lines do
    -- Get the content of the current line
    local line_content = vim.fn.getline(line)
    -- "^" -> Ensures the match is at the start of the line
    -- string.rep("#", level) -> Creates a string with 'level' number of "#" characters
    -- "%s" -> Matches any whitespace character after the "#" characters
    -- So this will match `## `, `### `, `#### ` for example, which are markdown headings
    if line_content:match('^' .. string.rep('#', level) .. '%s') then
      -- Move the cursor to the current line without adding to jumplist
      vim.cmd(string.format('keepjumps call cursor(%d, 1)', line))
      -- Check if the current line has a fold level > 0
      local current_foldlevel = vim.fn.foldlevel(line)
      if current_foldlevel > 0 then
        -- Fold the heading if it matches the level
        if vim.fn.foldclosed(line) == -1 then
          vim.cmd('normal! za')
        end
        -- else
        --   vim.notify("No fold at line " .. line, vim.log.levels.WARN)
      end
    end
  end
end

local function fold_markdown_headings(levels)
  -- I save the view to know where to jump back after folding
  local saved_view = vim.fn.winsaveview()
  for _, level in ipairs(levels) do
    fold_headings_of_level(level)
  end
  vim.cmd('nohlsearch')
  -- Restore the view to jump to where I was
  vim.fn.winrestview(saved_view)
end

-- HACK: Fold markdown headings in Neovim with a keymap
-- https://youtu.be/EYczZLNEnIY
--
-- Keymap for folding markdown headings of level 1 or above
vim.keymap.set('n', 'zj', function()
  -- "Update" saves only if the buffer has been modified since the last save
  vim.cmd('silent update')
  -- vim.keymap.set("n", "<leader>mfj", function()
  -- Reloads the file to refresh folds, otheriise you have to re-open neovim
  vim.cmd('edit!')
  -- Unfold everything first or I had issues
  vim.cmd('normal! zR')
  fold_markdown_headings({ 6, 5, 4, 3, 2, 1 })
  vim.cmd('normal! zz') -- center the cursor line on screen
end, { desc = '[P]Fold all headings level 1 or above' })

-- HACK: Fold markdown headings in Neovim with a keymap
-- https://youtu.be/EYczZLNEnIY
--
-- Keymap for folding markdown headings of level 2 or above
-- I know, it reads like "madafaka" but "k" for me means "2"
vim.keymap.set('n', 'zk', function()
  -- "Update" saves only if the buffer has been modified since the last save
  vim.cmd('silent update')
  -- vim.keymap.set("n", "<leader>mfk", function()
  -- Reloads the file to refresh folds, otherwise you have to re-open neovim
  vim.cmd('edit!')
  -- Unfold everything first or I had issues
  vim.cmd('normal! zR')
  fold_markdown_headings({ 6, 5, 4, 3, 2 })
  vim.cmd('normal! zz') -- center the cursor line on screen
end, { desc = '[P]Fold all headings level 2 or above' })

-- HACK: Fold markdown headings in Neovim with a keymap
-- https://youtu.be/EYczZLNEnIY
--
-- Keymap for folding markdown headings of level 3 or above
vim.keymap.set('n', 'zl', function()
  -- "Update" saves only if the buffer has been modified since the last save
  vim.cmd('silent update')
  -- vim.keymap.set("n", "<leader>mfl", function()
  -- Reloads the file to refresh folds, otherwise you have to re-open neovim
  vim.cmd('edit!')
  -- Unfold everything first or I had issues
  vim.cmd('normal! zR')
  fold_markdown_headings({ 6, 5, 4, 3 })
  vim.cmd('normal! zz') -- center the cursor line on screen
end, { desc = '[P]Fold all headings level 3 or above' })

-- HACK: Fold markdown headings in Neovim with a keymap
-- https://youtu.be/EYczZLNEnIY
--
-- Keymap for folding markdown headings of level 4 or above
vim.keymap.set('n', 'z;', function()
  -- "Update" saves only if the buffer has been modified since the last save
  vim.cmd('silent update')
  -- vim.keymap.set("n", "<leader>mf;", function()
  -- Reloads the file to refresh folds, otherwise you have to re-open neovim
  vim.cmd('edit!')
  -- Unfold everything first or I had issues
  vim.cmd('normal! zR')
  fold_markdown_headings({ 6, 5, 4 })
  vim.cmd('normal! zz') -- center the cursor line on screen
end, { desc = '[P]Fold all headings level 4 or above' })

-- HACK: Fold markdown headings in Neovim with a keymap
-- https://youtu.be/EYczZLNEnIY
--
-- Use <CR> to fold when in normal mode
-- To see help about folds use `:help fold`
vim.keymap.set('n', '<CR>', function()
  -- Get the current line number
  local line = vim.fn.line('.')
  -- Get the fold level of the current line
  local foldlevel = vim.fn.foldlevel(line)
  if foldlevel == 0 then
    vim.notify('No fold found', vim.log.levels.INFO)
  else
    vim.cmd('normal! za')
    vim.cmd('normal! zz') -- center the cursor line on screen
  end
end, { desc = '[P]Toggle fold' })

-- HACK: Fold markdown headings in Neovim with a keymap
-- https://youtu.be/EYczZLNEnIY
--
-- Keymap for unfolding markdown headings of level 2 or above
-- Changed all the markdown folding and unfolding keymaps from <leader>mfj to
-- zj, zk, zl, z; and zu respectively lamw25wmal
vim.keymap.set('n', 'zu', function()
  -- "Update" saves only if the buffer has been modified since the last save
  vim.cmd('silent update')
  -- vim.keymap.set("n", "<leader>mfu", function()
  -- Reloads the file to reflect the changes
  vim.cmd('edit!')
  vim.cmd('normal! zR') -- Unfold all headings
  vim.cmd('normal! zz') -- center the cursor line on screen
end, { desc = '[P]Unfold all headings level 2 or above' })

-- HACK: Fold markdown headings in Neovim with a keymap
-- https://youtu.be/EYczZLNEnIY
--
-- gk jummps to the markdown heading above and then folds it
-- zi by default toggles folding, but I don't need it lamw25wmal
vim.keymap.set('n', 'zi', function()
  -- "Update" saves only if the buffer has been modified since the last save
  vim.cmd('silent update')
  -- Difference between normal and normal!
  -- - `normal` executes the command and respects any mappings that might be defined.
  -- - `normal!` executes the command in a "raw" mode, ignoring any mappings.
  vim.cmd('normal gk')
  -- This is to fold the line under the cursor
  vim.cmd('normal! za')
  vim.cmd('normal! zz') -- center the cursor line on screen
end, { desc = '[P]Fold the heading cursor currently on' })

-------------------------------------------------------------------------------
--                         End Folding section
-------------------------------------------------------------------------------

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- check if we are an unraid system
vim.g.has_unraid = vim.fn.filereadable '/etc/unraid-version' ~= 0

vim.g.php_htmlInStrings = 1 --Syntax highlight HTML code inside PHP strings.
vim.g.php_sql_query = 1 --Syntax highlight SQL code inside PHP strings.
vim.g.php_noShortTags = 1 --Disable PHP short tags.

-- Load options and keymaps
require('vim-opts')
require('vim-keymaps')

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Disable line numbers etc on various file types
-- TODO: convert these to an after/ftplugin?
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Formatting options for gitcommits',
  pattern = 'gitcommit',
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.textwidth = 0
    vim.opt_local.colorcolumn = ''
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Formatting options for vimwiki',
  pattern = 'vimwiki',
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.textwidth = 0
    vim.opt_local.colorcolumn = ''
  end,
})

-- Set the TMUX title to the file name of current buffer
-- This requires the following tmux settings:
--   set -g allow-rename on
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', 'BufFilePost', 'BufWritePost' }, {
  callback = function()
    local filename = vim.fn.expand('%:t')
    if filename == '' then
      return
    end
    -- Special case for Zettelkasten files so I can quick switch to them using my tmux bindings
    if string.match(vim.fn.expand('%:p'), 'data/SYNC/zk') then
      return
    end
    -- truncate to len characters
    local len = 15
    local shortname = #filename > len and filename:sub(1, len) .. '…' or filename
    -- Update tmux window name
    io.write('\027kVI:' .. shortname .. '\027\\')
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
  { import = 'plugins' },

  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  -- NOTE: Plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  --
  -- Use `opts = {}` to force a plugin to be loaded.
  --
  -- Save and load buffers (a session) automatically for each folder

  -- -------------------------------------

  -- The following two comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  -- require 'kickstart.plugins.autopairs',
  -- require 'kickstart.plugins.neo-tree',
  -- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
