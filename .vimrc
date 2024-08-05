" Auto install plugin manager if it is not already.  ref: https://github.com/junegunn/vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

" Check if we are on an unraid OS so we can ignore some plugins
let has_unraid = filereadable('/etc/unraid-version')

call plug#begin('~/.vim/plugged')
Plug 'vimwiki/vimwiki'
"Plug 'jlanzarotta/bufexplorer'
" disable fugitive in favor of lazygit
"Plug 'tpope/vim-fugitive'      " Git integrations - compare to lazygit
Plug 'bitc/vim-bad-whitespace'
"Plug 'crusoexia/vim-monokai'
Plug 'vim-pandoc/vim-pandoc'  " Tools for various markdown styles
Plug 'vim-pandoc/vim-pandoc-syntax'
" If you don't have nodejs and yarn
" use pre build, add 'vim-plug' to the filetype list so vim-plug can update this plugin
" see: https://github.com/iamcco/markdown-preview.nvim/issues/50
Plug 'iamcco/markdown-preview.nvim', has_unraid ? { 'on': [] } : { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug'] }
Plug 'github/copilot.vim', has_unraid ? { 'on': [] } : {}
"Plug 'majutsushi/tagbar'       " Needs ctags cli installed
"Plug 'mileszs/ack.vim'         " Needs ack cli installed
Plug 'tpope/vim-surround'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }  "fuzzy finder
Plug 'junegunn/fzf.vim'
Plug 'NLKNguyen/papercolor-theme'
Plug 'rodjek/vim-puppet'
Plug 'hashivim/vim-terraform'
Plug 'dense-analysis/ale' "Replacement for syntastic
"Plug 'ap/vim-css-color' "Color preview for css
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'christoomey/vim-tmux-navigator'
"TODO look into lazyvim, ripgrep, ag, or silversearcher-ag type plugins
call plug#end()

if filereadable(glob("~/.vim/.vimrc"))
  source ~/.vim/.vimrc
endif

set nocompatible
filetype plugin on
syntax on

" disable indenting for comments on python and yaml
autocmd BufNewFile,BufReadPost * if &filetype == "python" | set indentkeys-=0# | endif
autocmd BufNewFile,BufReadPost * if &filetype == "yaml" | set indentkeys-=0# | endif

autocmd FileType gitcommit setlocal nonumber norelativenumber textwidth=0

set t_Co=256 " ensure enough colors for airline
colorscheme PaperColor       " set color scheme
let g:PaperColor_Theme_Options = {
  \   'theme': {
  \     'default.dark': {
  \       'override' : {
  \         'color00' : ['#000000', '232'],
  \         'linenumber_bg' : ['#080808', '232']
  \       }
  \     }
  \   }
  \ }
set background=dark     " on a dark background

" Newer vim seems to like pascal instead of puppet
au BufNewFile,BufRead *.pp  setlocal filetype=puppet

let g:terraform_fmt_on_save=1

" Pandoc settings (basically takes over markdown)
autocmd FileType pandoc setlocal nonumber norelativenumber colorcolumn= textwidth=0 spell
let g:pandoc#filetypes#handled = ["pandoc", "markdown"]
let g:pandoc#filetypes#pandoc_markdown = 0
let g:pandoc#modules#disabled = ["folding"]

""" Markdown preview browser
let g:mkdp_browser = 'safari' " is safari for now, I dont expect to use elsewhere
let g:mkdp_auto_start = 1 " auto open preview on entering markdown file TBD
let g:mkdp_auto_close = 0
let g:mkdp_combine_preview = 1 " combine with auto close

""" ALE settings
let g:ale_yaml_yamllint_options='-d "{extends: relaxed, rules: {line-length: disable}}"' " disable line length check

""" Airline plugin
let g:airline#extensions#tabline#enabled = 1
"let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline_theme='minimalist'
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_left_sep = '▶'
let g:airline_right_sep = '◀'
let g:airline_symbols.crypt = '🔒'
let g:airline_symbols.colnr = ' : '
let g:airline_symbols.linenr = ' : '
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.branch = '⎇'
"let g:airline_symbols.dirty='⚡'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.spell = 'Ꞩ'
let g:airline_symbols.notexists = 'Ɇ'
let g:airline_symbols.whitespace = 'Ξ'
""" End Airline plugin

"""" vimwiki settings
" FYI mac vim does not have +conceal by default
let personal = {}
let personal.path = '~/data/SYNC/wiki/'
let personal.syntax = 'markdown'
let personal.ext = '.md'
let work = {}
let work.path = '~/data/workwiki/'
let work.ext = '.md'
let g:vimwiki_list = [personal, work]
let g:vimwiki_listsyms = ' ○◐●✓'
let g:vimwiki_global_ext = 0
" vimwiki steals tab completion, disable it since I dont use tables much at all
let g:vimwiki_key_mappings = { 'table_mappings': 0 }
autocmd FileType vimwiki setlocal nonumber norelativenumber colorcolumn= textwidth=0
"""" end vimwiki

"""" copilot settings
" re-enable some default disabled filetypes
let g:copilot_filetypes = {
  \ 'gitcommit': v:true,
  \ 'markdown': v:true,
  \ 'yaml': v:true
  \ }
" disable copilot for large files over 100k
autocmd BufReadPre *
  \ let f=getfsize(expand("<afile>"))
  \ | if f > 100000 || f == -2
  \ | let b:copilot_enabled = v:false
  \ | endif
"""" end copilot

let php_folding = 1        "Set PHP folding of classes and functions.
let php_htmlInStrings = 1  "Syntax highlight HTML code inside PHP strings.
let php_sql_query = 1      "Syntax highlight SQL code inside PHP strings.
let php_noShortTags = 1    "Disable PHP short tags.

" basic formatting {{{
"set autoread            " Auto load file when changed from outside vim
set scrolloff=10
set shiftwidth=2        " I have no idea why you would use anything else
set softtabstop=2       " backspace over a shift width
set tabstop=2           " tabs are for shifting
set expandtab           " but hard tabs are the devil
set smarttab            " initial tab based on shiftwidth
set shiftround          " indent in multiples of shiftwidth
set textwidth=78        " I hate long lines
set autoindent          " always set autoindenting on
set smartindent         " be smart about indenting new lines
set number              " turn on linenumbers
set relativenumber      " line numbers relative to current position
" but be smarter about indenting comments
inoremap # #
" cindent settings
set cinkeys=0{,0},:,!^F,!<Tab>,o,O,e
set cinoptions=>1s,n-1s,:1s,=1s,(2s,+2s
set formatoptions=croq  " wrap comments, insert leaders and format with gq
try
set formatoptions+=j    " remove extra comment leaders when joining lines
catch
endtry
set formatoptions+=n    " recognize numbered lists when formatting
set formatoptions+=1    " don't end lines with single letter words
set formatoptions+=b    " don't break existing long lines
set formatoptions+=t    " auto-wrap text too
" }}}

set wildchar=<Tab> wildmenu wildmode=longest:full,full wildoptions=pum

" backups, swap and history {{{
set noundofile          " don't keep undo file
set nobackup            " don't keep a backup file
set nowritebackup       " seriously, no backup file
if !has('nvim')
  set viminfo='10,f1,%30,<50,:50,n~/.viminfo
                        " marks for 10 files
                        " store file marks
                        " save 30 buffer list
                        " max 50 lines for each register
                        " remember 50 commands
                        " write to ~/.viminfo
else
  " Do nothing here to use the neovim default
  " or do soemething like:
  " set viminfo+=n~/.shada
endif

set history=50          " keep 50 lines of command line history
" }}}

set pastetoggle=<C-P>   " easy paste switch
"set paste               " turn on paste mode by default, disabled due to copilot

" status line, commands and splitters {{{
set laststatus=2        " always show status line
set shortmess=atI       " always show short messages
set showcmd             " display incomplete commands
set fillchars=vert:\ ,stl:\ ,stlnc:\  "no funny fill chars in splitters
set splitbelow
set splitright

"function! SyntaxItem()
"  return synIDattr(synID(line("."),col("."),1),"name")
"endfunction

"set statusline =
"set statusline +=%-2.2n             " buffer number
"set statusline +=\ %{FugitiveStatusline()} " git status
"set statusline +=\ %<%F             " full path
"set statusline +=\ [%Y%R%W]         " filetype, readonly?, preview?
"set statusline +=%{'~'[&pm=='']}    " patch mode?
"set statusline +=%M                 " Modified?
""set statusline +=%#warningmsg#%{SyntasticStatuslineFlag()}%* " syntax check
"set statusline +=%=                 " float right
"set statusline +=%#error#%{&paste?'[paste]':''}%* " Paste mode?
"" set statusline +=%{SyntaxItem()}    " syntax highlight group under cursor
"set statusline +=\ %{&ff}           " file format
"set statusline +=\ %{&fenc}         " encoding
"set statusline +=\ %l,%c%V          " line, col-virt col (like :set ruler)
"" }}}

" encoding and charsets {{{
set encoding=utf-8      " you don't use utf-8? ಠ_ಠ
let &termencoding = &encoding
try
  lang en_US
catch
endtry
set fileformats=unix,dos,mac  " preferred file format order
" }}}


"""" would love to but the colors suck with solarize in iterm2
" highlight 80 and 120+ column
highlight ColorColumn ctermbg=8
"let &colorcolumn="80,".join(range(120,999),",")
set colorcolumn=80

" Set the linenumber color
"""highlight LineNr ctermfg=black



" DEFINE SOME KEYMAPS

let mapleader=","

" Tab management
nnoremap tl :tabnext<CR>
nnoremap th :tabprev<CR>
nnoremap tp :tabprev<CR>
nnoremap tn :tabnext<CR>
nnoremap tt :tabnew<CR>
nnoremap tc :tabclose<CR>
nnoremap tx :tabclose<CR>

" Buffer management - maybe map to something other than f
nnoremap ff :enew<CR>   " new buffer
nnoremap fp :bprev<CR>  " previous buffer
nnoremap fn :bnext<CR>  " next buffer
nnoremap fx :bw<CR>     " close buffer

" Open a terminal
nnoremap <leader>t :terminal<CR>

" ALE related
nnoremap <leader>ln :ALENextWrap<CR>
nnoremap <leader>lp :ALEPreviousWrap<CR>

"" FZF related
" bufferlist
nnoremap <Leader>b :Buffers<CR>
nnoremap <leader>s :<C-u>FZF<CR>
nnoremap <leader><tab> :<C-u>FZF<CR>

" NO, write it for real!
nnoremap <leader>W :w !sudo tee % > /dev/null

" Reload vim configuration file
nnoremap <leader>vr :source $MYVIMRC<CR>

" Some Git related maps - possibly remove if lazygit performs
nnoremap <leader>g :Git<CR>
nnoremap <leader>gu :Git push<CR>
nnoremap <leader>gd :Git diff<CR>

" Toggle conceal level
nnoremap <leader>c :set <C-R>=&conceallevel ? 'conceallevel=0' : 'conceallevel=2'<CR><CR>

" setup shortcut to toggle numbers
noremap <leader>l :call ToggleLineNumber()<CR>

" Toggle markdown preview
noremap <leader>md :MarkdownPreviewToggle<CR>

" Toggle the linenumbers
function! ToggleLineNumber()
  if v:version > 703
    set norelativenumber!
  endif
  set nonumber!
endfunction

" Toggle spell check
nnoremap <leader>sp :call ToggleSpell()<CR>
function! ToggleSpell()
  set spell!
endfunction

" Go back to last misspelled word and pick first suggestion.
nnoremap <leader>ss <Esc>[s1z=

