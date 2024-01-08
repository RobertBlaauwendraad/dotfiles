"*********************************************************************
" Robert's vimrc
"
"*********************************************************************

" Turn on syntax highlighting
syntax on

" Show line numbers
set number

" Showfile stats
set ruler

" Use system clipboard
set clipboard=unnamed,unnamedplus

" Ignore case of searches
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight dynamically as pattern is typed
set incsearch

" Hard mode
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
inoremap <Up> <NOP>
inoremap <Down> <NOP>
inoremap <Left> <NOP>
inoremap <Right> <NOP>

filetype plugin indent on
" Show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab
