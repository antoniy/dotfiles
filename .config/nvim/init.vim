" -------- General settings {{{
" -----------------------------
" Read documentation about each option by executing :h <option>

let mapleader = ","

map <leader>? :verbose map <CR><CR>

set nocompatible                  " do not preserve compatibility with Vi
set modifiable                    " buffer contents can be modified
set encoding=utf-8                " default character encoding
set autoread                      " detect when a file has been modified externally
set spelllang=en,bg               " languages to check for spelling (english, greek)
set spellsuggest=10               " number of suggestions for correct spelling
set updatetime=500                " time of idleness is miliseconds before saving swapfile
set undolevels=1000               " how many undo levels to keep in memory
set showcmd                       " show command in last line of the screen
set nostartofline                 " keep cursor in the same column when moving between lines
set errorbells                    " ring the bell for errors
set visualbell                    " then use a flash instead of a beep sound
set belloff=esc                   " hitting escape in normal mode does not constitute an error
set confirm                       " ask for confirmation when quitting a file that has changes
set hidden                        " hide buffers
set autoindent                    " indent automatically (useful for formatoptions)
set smartindent
set expandtab                     " use spaces instead of tab
set tabstop=2                     " tab character width
set shiftwidth=2                  " needs to be the same as tabstop
set smartcase                     " ignore case if the search contains majuscules
set hlsearch                      " highlight all matches of last search
set incsearch                     " enable incremental searching (get feedback as you type)
set backspace=indent,eol,start    " backspace key should delete indentation, line ends, characters
set whichwrap=s,b                 " which motion keys should jump to the above/below wrapped line
"set textwidth=72                  " hard wrap at this column
set joinspaces                    " insert two spaces after puncutation marks when joining multiple lines into one
set wildmenu                      " enable tab completion with suggestions when executing commands
set wildmode=longest,list,full    " settings for how to complete matched strings
set modeline                    " vim reads the modeline to execute commands for the current file
set timeoutlen=1000 ttimeoutlen=0 " timeoutlen is used for mapping delays, ttimoutlen - for key code delays. The purpose of this configuration is to eliminate the delay when we go from visual mode into insert mode.
set clipboard=unnamedplus         " use system clipboard for copy/paste

" better word wrapping: breaks at spaces or hyphens
set formatoptions=l
set lbr

" Use F5 to toggle paste mode
set pastetoggle=<f5>

" }}}
" -------- Plugins {{{
" --------------------

call plug#begin('~/.config/nvim/plugged/')

" Appearance
Plug 'chriskempson/base16-vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Markdown
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'mzlogin/vim-markdown-toc'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }

" Syntax
Plug 'kovetskiy/sxhkd-vim'
Plug 'udalov/kotlin-vim'    
Plug 'PotatoesMaster/i3-vim-syntax'

" Git 
Plug 'tpope/vim-fugitive'

" Code/text tools
Plug 'tpope/vim-surround'
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-commentary'
Plug 'terryma/vim-multiple-cursors'

" File finders
Plug 'scrooloose/nerdtree'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/gv.vim'

call plug#end()            " required

" }}}
" -------- Appearance {{{
" -----------------------

" enable syntax highlighting
syntax on

" turn hybrid line numbers on
set number relativenumber

" Default color scheme
colorscheme base16-tomorrow-night " enable base16 theme

" set airline theme
let g:airline_theme='base16_default'
" enable airline powerline symbols
let g:airline_powerline_fonts = 1

" Switch between dark and light theme using <leader>d and <leader>l respectively
nnoremap <leader>dark :colorscheme base16-tomorrow-night<CR> :AirlineTheme base16_default<CR>
nnoremap <leader>light :colorscheme base16-tomorrow<CR> :AirlineTheme tomorrow<CR>

" Allow for transparent background
hi Normal guibg=NONE ctermbg=NONE

" needed for proper syntax highlighting in tmux
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors

" }}}
" -------- Config Reload {{{
" --------------------------
" watch for changes then auto source vimrc
" http://stackoverflow.com/a/2403926
augroup myvimrc
    au!
    au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc,init.vim so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END

" Reload config file manually
" noremap <leader>r :so %<CR>
noremap <leader>reload :so $MYVIMRC<CR>

" }}}
" -------- Nerd tree {{{
" ----------------------
map <leader>n :NERDTreeToggle<CR>

" CtrlP most recently used shortcut
map <leader>m :CtrlPMRU<CR>
map <leader>b :CtrlPBuffer<CR>

" }}}
" -------- Splits {{{
" -----------------------------------
set splitbelow splitright         " Splits open at the bottom and right, which is non-retarded, unlike vim defaults.

" Ctrl+{h,j,k,l} move between splits
nnoremap <C-H> <C-W><C-H>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>

" Ctrl+W + {S,V} split whole screen horizontal/vertical
nnoremap <C-W>S :botright new<CR>
nnoremap <C-W>V :botright vnew<CR>

" }}}
" -------- Markdown {{{
" -----------------------------------------
" https://github.com/iamcco/markdown-preview.nvim
" https://github.com/plasticboy/vim-markdown

" disable vim-markdown folding so we can use the vim-markdown-folding plugin instead
let g:vim_markdown_folding_style_pythonic = 1
" set enable conceal with simple style
set conceallevel=2
" work with no extensions for markdown files in links - default for github, gitlab, etc
let g:vim_markdown_no_extensions_in_markdown = 1
" follow file#anchor links
let g:vim_markdown_follow_anchor = 1

" open the server to the world not just localhost
let g:mkdp_open_to_the_world = 1
" Set default port for the preview server
let g:mkdp_port = '8894'
" Show preview URL in console when the preview is started
let g:mkdp_echo_preview_url = 1

" add mapping to trigger markdown preview manually
nmap <leader>md <Plug>MarkdownPreviewToggle
" format the ascii table under the cursor
map <leader>tf :TableFormat<CR>
" mapping to create markdown link out of the current WORD: word -> [word]()
map <leader>l diWa[]() <ESC>F[pf(

" }}}
" -------- Folding {{{
" --------------------------------------------------
" enable folding; http://vim.wikia.com/wiki/Folding
set foldmethod=marker

" fold color
hi Folded cterm=bold ctermfg=DarkBlue ctermbg=none
hi FoldColumn cterm=bold ctermfg=DarkBlue ctermbg=none

"refocus folds; close any other fold except the one that you are on
nnoremap <leader>z zMzvzz

"}}}
" -------- Motions and Moves {{{
" ------------------------------
" Go to beginning or end of line
noremap H ^
noremap L $

" keep search matches in the middle of the window.
nnoremap n nzzzv
nnoremap N Nzzzv

" clear matching after search
noremap <silent> <leader><space> :noh<cr>:call clearmatches()<cr>

" Don't move on *
nnoremap * *<c-o>

" Show fuzzy picker for open buffers
nnoremap <leader>ls :Buffers<CR>

" Show fuzzy picker for recently editted files
nnoremap <leader>h :History<CR>
" }}}
" -------- Sudo feature {{{
" ----------------------------------------------------------
" write file if you forgot to give it sudo permission
" tutorial video: http://www.youtube.com/watch?v=C6xqO4Z1nIo
map <leader>sudo :w !sudo tee % <CR><CR>
"}}}
