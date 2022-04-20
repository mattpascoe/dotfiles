" Auto install plugin manager if it is not already.  ref: https://github.com/junegunn/vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'jlanzarotta/bufexplorer'
Plug 'tpope/vim-fugitive'      " Git integrations
Plug 'scrooloose/syntastic'    " syntax and lint checker
Plug 'bitc/vim-bad-whitespace'
"Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
"Plug 'crusoexia/vim-monokai'
"Plug 'vim-pandoc/vim-pandoc'  " Tools for various markdown styles
"Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'majutsushi/tagbar'
Plug 'mileszs/ack.vim'
Plug 'tpope/vim-surround'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }  "fuzzy finder
call plug#end()

if filereadable(glob("~/.vim/.vimrc"))
  source ~/.vim/.vimrc
endif

" Newer vim seems to like pascal instead of puppet
au BufNewFile,BufRead *.pp  setlocal filetype=puppet

let g:syntastic_check_on_open = 0
let g:syntastic_javascript_checkers = ['jsl', 'jshint']
let g:syntastic_php_checkers=['php', 'phpcs']
let g:syntastic_php_phpcs_args='--standard=PSR2 -n'

" Exclude specific puppet-lint checks
let g:syntastic_puppet_puppetlint_args='--no-80chars-check --no-nested_classes_or_defines-check --no-autoloader_layout-check'

" Took bd808s stuff..........
" bd808's handy vimrc

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
"" set nocompatible

" Automatically close NERDTree when you open a file
let NERDTreeQuitOnOpen=1

" basic formatting {{{
"set autoread            " Auto load file when changed from outside vim
set scrolloff=5
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

set wildchar=<Tab> wildmenu wildmode=full
nnoremap fh :bprev<CR>  " previous buffer
nnoremap fl :bnext<CR>  " next buffer
nnoremap fc :bw<CR>     " close buffer


" backups, swap and history {{{
set nobackup            " don't keep a backup file
set nowritebackup       " seriously, no backup file
set viminfo='10,f1,<50,:50,n~/.viminfo
                        " marks for 10 files
                        " store file marks
                        " max 50 lines for each register
                        " remember 50 commands
                        " write to ~/.viminfo
set history=50          " keep 50 lines of command line history
" }}}

set pastetoggle=<C-P>   " easy paste switch
set paste               " turn on paste mode by default

" status line, commands and splitters {{{
set laststatus=2        " always show status line
set shortmess=atI       " always show short messages
set showcmd             " display incomplete commands
set fillchars=vert:\ ,stl:\ ,stlnc:\  "no funny fill chars in splitters
set splitbelow
set splitright

function! SyntaxItem()
  return synIDattr(synID(line("."),col("."),1),"name")
endfunction

set statusline =
set statusline +=%-2.2n             " buffer number
set statusline +=\ %{FugitiveStatusline()} " git status
set statusline +=\ %<%F             " full path
set statusline +=\ [%Y%R%W]         " filetype, readonly?, preview?
set statusline +=%{'~'[&pm=='']}    " patch mode?
set statusline +=%M                 " Modified?
"set statusline +=%#warningmsg#%{SyntasticStatuslineFlag()}%* " syntax check
set statusline +=%=                 " float right
set statusline +=%#error#%{&paste?'[paste]':''}%* " Paste mode?
" set statusline +=%{SyntaxItem()}    " syntax highlight group under cursor
set statusline +=\ %{&ff}           " file format
set statusline +=\ %{&fenc}         " encoding
set statusline +=\ %l,%c%V          " line, col-virt col (like :set ruler)
" }}}

" encoding and charsets {{{
set encoding=utf-8      " you don't use utf-8? ಠ_ಠ
let &termencoding = &encoding
try
  lang en_US
catch
endtry
set fileformats=unix,dos,mac  " preferred file format order
" }}}


" syntax highlighting {{{
syntax enable           " enable syntax highlighting
"colorscheme desert      " set color scheme
colorscheme slate       " set color scheme
set background=dark     " on a dark background
" }}}

"""" would love to but the colors suck with solarize in iterm2
" highlight 80 and 120+ column
highlight ColorColumn ctermbg=0
"let &colorcolumn="80,".join(range(120,999),",")
set colorcolumn=80

" Set the linenumber color
"""highlight LineNr ctermfg=black



" DEFINE SOME KEYMAPS

let mapleader=","

" Tab management
nnoremap tl :tabnext<CR>
nnoremap th :tabprev<CR>
nnoremap tn :tabnew<CR>
nnoremap tc :tabclose<CR>

nnoremap <leader>s :<C-u>FZF<CR>
nnoremap <leader>W :w !sudo tee % > /dev/null

" setup shortcut to toggle numbers
noremap <leader>r :call ToggleLineNumber()<CR>


" Toggle the linenumbers
function! ToggleLineNumber()
  if v:version > 703
    set norelativenumber!
  endif
  set nonumber!
endfunction
