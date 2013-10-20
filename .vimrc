" Took bd808s stuff..........
" bd808's handy vimrc

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
"" set nocompatible


" basic formatting {{{
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
highlight LineNr ctermfg=black
