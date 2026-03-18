" vim: foldmethod=marker
" __     ___              __              _     _________    _    ____
" \ \   / (_)_ __ ___    / _| ___  _ __  | |   |__  / ___|  / \  / ___|
"  \ \ / /| | '_ ` _ \  | |_ / _ \| '__| | |     / /|___ \ / _ \| |
"   \ V / | | | | | | | |  _| (_) | |    | |___ / /_ ___) / ___ \ |___
"    \_/  |_|_| |_| |_| |_|  \___/|_|    |_____/____|____/_/   \_\____|
"

" -------- General settings {{{1

set spelllang=en,bg               " languages to check for spelling
set spellsuggest=10               " number of suggestions for correct spelling
set updatetime=100                " ms of idle before saving swapfile (also drives vim-signify refresh)
set showcmd                       " show command in last line of the screen
set nostartofline                 " keep cursor in the same column when moving between lines
set errorbells                    " ring the bell for errors
set visualbell                    " use a flash instead of a beep sound
set belloff=esc                   " hitting escape in normal mode is not an error
set confirm                       " ask for confirmation when quitting unsaved changes
set hidden                        " allow switching buffers without saving
set autoindent                    " indent automatically
set smartindent
set expandtab                     " use spaces instead of tabs
set tabstop=2                     " tab character width
set shiftwidth=2                  " indent width (match tabstop)
set smartcase                     " case-insensitive search unless query has uppercase
set hlsearch                      " highlight all matches of last search
set incsearch                     " show matches incrementally as you type
set whichwrap=s,b                 " allow space/backspace to move across line boundaries
set joinspaces                    " insert two spaces after punctuation when joining lines
set wildmenu                      " tab-completion menu for commands
set wildmode=longest,list,full    " completion behaviour: longest common, then list, then cycle
set modeline                      " read per-file vim modelines
set timeoutlen=1000 ttimeoutlen=0 " no delay when leaving insert mode (key code timeout = 0)

" better word wrapping: break at spaces or hyphens rather than mid-word
set formatoptions=l
set lbr

set cursorline                    " highlight the current line
set signcolumn=yes                " always show the sign column (git, LSP diagnostics)

" -------- Mappings {{{1

"---------------------------------------------------------------------------"
" Commands \ Modes | Normal | Insert | Command | Visual | Select | Operator |
"------------------|--------|--------|---------|--------|--------|----------|
" map  / noremap   |    @   |   -    |    -    |   @    |   @    |    @     |
" nmap / nnoremap  |    @   |   -    |    -    |   -    |   -    |    -     |
" vmap / vnoremap  |    -   |   -    |    -    |   @    |   @    |    -     |
" omap / onoremap  |    -   |   -    |    -    |   -    |   -    |    @     |
" xmap / xnoremap  |    -   |   -    |    -    |   @    |   -    |    -     |
" smap / snoremap  |    -   |   -    |    -    |   -    |   @    |    -     |
" map! / noremap!  |    -   |   @    |    @    |   -    |   -    |    -     |
" imap / inoremap  |    -   |   @    |    -    |   -    |   -    |    -     |
" cmap / cnoremap  |    -   |   -    |    @    |   -    |   -    |    -     |
"---------------------------------------------------------------------------"

let mapleader = " "

nnoremap <leader>? :verbose map<CR>

" Emacs-style movement in insert and command mode
noremap! <C-F> <Right>
noremap! <C-B> <Left>
noremap! <C-D> <Del>

cnoremap <C-A> <HOME>
cnoremap <C-E> <END>
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" Resize the current window with shift+arrow keys
noremap <silent> <S-Left>  :<C-U>wincmd <<CR>
noremap <silent> <S-Right> :<C-U>wincmd ><CR>
noremap <silent> <S-Up>    :<C-U>wincmd -<CR>
noremap <silent> <S-Down>  :<C-U>wincmd +<CR>

" Change current directory to the directory of the current file
nnoremap <silent> <Leader>cd :<C-U>cd %:p:h<CR>

" Overwrite the current line with yanked text
nnoremap <silent> go  pk"_dd

nnoremap '.  :e %:h<C-d>

" -------- Plugins {{{1

" Auto-install vim-plug if missing
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/plugged/')

" --- Appearance ---
Plug 'chriskempson/base16-vim'        " base16 colour schemes
Plug 'vim-airline/vim-airline'        " status/tabline
Plug 'vim-airline/vim-airline-themes' " themes for airline
Plug 'morhetz/gruvbox'                " gruvbox colour scheme

" --- Markdown ---
Plug 'plasticboy/vim-markdown'                                        " markdown syntax and folding
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } } " live browser preview

" --- Syntax ---
Plug 'sheerun/vim-polyglot'           " language pack (syntax + indent for 100+ languages)

" --- Git ---
Plug 'tpope/vim-fugitive'             " Git commands inside vim (:G, :Gblame, etc.)
Plug 'airblade/vim-gitgutter'         " show git diff markers in the sign column
Plug 'rhysd/git-messenger.vim'        " show the commit message under the cursor

" --- Code / text tools ---
Plug 'tpope/vim-surround'             " add/change/delete surrounding brackets, quotes, tags
Plug 'tpope/vim-commentary'           " toggle comments with gc
Plug 'terryma/vim-multiple-cursors'   " Ctrl+N multi-cursor editing
Plug 'alvan/vim-closetag'             " auto-close HTML/XML tags
Plug 'vim-scripts/ReplaceWithRegister' " gr motion to replace with register contents
Plug 'tpope/vim-repeat'               " make . repeat plugin mappings
Plug 'tpope/vim-speeddating'          " increment/decrement dates with C-A/C-X
Plug 'zainin/vim-mikrotik'            " MikroTik RouterOS syntax highlighting


" --- File finders ---
Plug 'junegunn/fzf', { 'dir': '~/.fzf' }     " fuzzy finder binary
Plug 'junegunn/fzf.vim'                       " fzf vim integration (Files, Buffers, Rg, etc.)
Plug 'junegunn/gv.vim'                        " git commit browser (:GV)
Plug 'preservim/nerdtree'                     " file system tree explorer

" --- Misc ---
Plug 'christoomey/vim-tmux-navigator'         " seamless pane navigation between vim and tmux
Plug 'tpope/vim-eunuch'                       " Unix shell commands (:Rename, :Delete, :Move, etc.)
Plug 'tpope/vim-unimpaired'                   " bracket mappings for common toggles (yob, yos, etc.)
Plug 'junegunn/goyo.vim'                      " distraction-free writing mode
Plug 'junegunn/limelight.vim'                 " dim all paragraphs except the current one
Plug 'skammer/vim-css-color'                  " highlight colour codes in their actual colour

call plug#end()

" Automatically install missing plugins on startup
autocmd VimEnter *
      \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
      \|   PlugInstall --sync | q
      \| endif

" -------- Appearance {{{1

syntax on

" Hybrid line numbers: absolute in insert mode, relative in normal mode
set number relativenumber

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" Gruvbox colour scheme
let g:gruvbox_italic=1
colorscheme gruvbox

" Airline status bar
let g:airline_theme='gruvbox'
let g:airline#extensions#tabline#enabled = 1 " show open buffers in the tabline

" needed for proper 24-bit colour in tmux
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors

" -------- Config Reload {{{1

" Auto-source vimrc on save
augroup myvimrc
    au!
    au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc,init.vim so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END

noremap <leader>reload :so $MYVIMRC<CR>

" -------- Splits {{{1

set splitbelow splitright         " open splits below and to the right

" Ctrl+W + {S,V} split the whole screen horizontally / vertically
nnoremap <C-W>S :botright new<CR>
nnoremap <C-W>V :botright vnew<CR>

" -------- Markdown {{{1

" https://github.com/iamcco/markdown-preview.nvim
" https://github.com/plasticboy/vim-markdown

" use pythonic folding style for headings
let g:vim_markdown_folding_style_pythonic = 1
" conceal markup characters with simple style
set conceallevel=2
" treat links without extensions as valid (default for GitHub/GitLab)
let g:vim_markdown_no_extensions_in_markdown = 1
" follow anchor links (file#section)
let g:vim_markdown_follow_anchor = 1

" open the preview server to the world (not just localhost)
let g:mkdp_open_to_the_world = 1
" fixed port for the preview server
let g:mkdp_port = '8894'
" print the preview URL in the console when started
let g:mkdp_echo_preview_url = 1

" --- Markdown mappings ---
nmap <leader>md <Plug>MarkdownPreviewToggle
nnoremap <leader>tf :TableFormat<CR>
" wrap the current WORD as a markdown link: word -> [word]()
nnoremap <leader>l diWa[]() <ESC>F[pf(
" open the personal wiki index
nmap <silent> <leader>ww :e $HOME/.wiki/Home.md<CR>

" -------- Folding {{{1

set foldmethod=marker

" fold colours
hi Folded cterm=bold ctermfg=DarkBlue ctermbg=none
hi FoldColumn cterm=bold ctermfg=DarkBlue ctermbg=none

" close all folds except the one the cursor is in
nnoremap <leader>z zMzvzz

" show a * in the foldtext when the folded region contains git changes
set foldtext=gitgutter#fold#foldtext()

" automatic syntax folding for XML files
augroup XML
  autocmd!
  autocmd FileType xml let g:xml_syntax_folding=1
  autocmd FileType xml setlocal foldmethod=syntax fdn=2 fdl=1
  autocmd FileType xml :syntax on
augroup END

" -------- Aliases {{{1

nnoremap <leader>wq :wq<CR>
nnoremap <leader>q  :q<CR>
nnoremap <leader>W  :w<CR>

" -------- Motions and Moves {{{1

" keep search matches vertically centred in the window
nnoremap n nzzzv
nnoremap N Nzzzv

" clear search highlights and match decorations
noremap <silent> ,, :noh<CR>:call clearmatches()<CR>

" * searches without jumping to the next match
nnoremap * *<C-o>

" buffer navigation
nnoremap gn :bn<CR>
nnoremap gp :bp<CR>

" jj exits insert mode
imap jj <Esc>

" -------- Git {{{1

let g:gitgutter_highlight_linenrs = 1

" hunk navigation
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)

" hunk stage / undo / preview
nmap ghs <Plug>(GitGutterStageHunk)
nmap ghu <Plug>(GitGutterUndoHunk)
nmap ghp <Plug>(GitGutterPreviewHunk)

" hunk text objects (remapped from default 'c' to 'h')
omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)

" git-messenger: press twice to focus the popup window, ? for options
nmap <C-w>m <Plug>(git-messenger)

" fugitive: open git status
nmap <silent> <leader>gg :G<CR>

" -------- Find Tools {{{1

" custom fzf commands for specific directories
command! -bang -nargs=? -complete=dir ProjectFiles call fzf#vim#files('~/projects/', <bang>0)
command! -bang -nargs=? -complete=dir DotFiles    call fzf#vim#files('~/.dotfiles/', <bang>0)

" hide preview window by default; toggle it with <C-?>
let $FZF_DEFAULT_OPTS="--preview-window=hidden"

nnoremap <silent> <leader>e  :Buffers<CR>
nnoremap <silent> <leader>h  :History<CR>
nnoremap <silent> <leader>ff :Files<CR>
nnoremap <silent> <leader>fg :GFiles<CR>
nnoremap <silent> <leader>fp :ProjectFiles<CR>
nnoremap <silent> <leader>fd :DotFiles<CR>

" NERDTree file explorer
nnoremap <leader>n :NERDTreeToggle<CR>
let NERDTreeWinSize=40
let NERDTreeIgnore=['\.pyc','\~$','\.swo$','\.swp$','\.git$','\.svn','\.idea$',
      \ '\.bzr','\.DS_Store','\.sass-cache','\.vagrant']
let NERDTreeQuitOnOpen=1
let NERDTreeDirArrows=1

" -------- Distraction Free Mode {{{1

nnoremap <silent> <leader>focus :Goyo<CR>

let g:goyo_width = '70%'

" enable / disable limelight alongside Goyo
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!

" -------- Closetag {{{1

" file extensions where auto-close is enabled
let g:closetag_filenames      = '*.html,*.xhtml,*.phtml,*.xml'
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx,*.xml'
let g:closetag_filetypes      = 'html,xhtml,phtml,xml'
let g:closetag_xhtml_filetypes = 'xhtml,jsx,xml'

" make non-closing tag matching case-sensitive
let g:closetag_emptyTags_caseSensitive = 1

" restrict auto-close to valid JSX/TSX regions
let g:closetag_regions = {
    \ 'typescript.tsx': 'jsxRegion,tsxRegion',
    \ 'javascript.jsx': 'jsxRegion',
    \ }

let g:closetag_shortcut       = '>'   " key to close the tag
let g:closetag_close_shortcut = '<leader>>' " insert > without closing

