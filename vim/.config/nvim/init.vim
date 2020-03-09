" vim: foldmethod=marker
" __     ___              __              _     _________    _    ____
" \ \   / (_)_ __ ___    / _| ___  _ __  | |   |__  / ___|  / \  / ___|
"  \ \ / /| | '_ ` _ \  | |_ / _ \| '__| | |     / /|___ \ / _ \| |
"   \ V / | | | | | | | |  _| (_) | |    | |___ / /_ ___) / ___ \ |___
"    \_/  |_|_| |_| |_| |_|  \___/|_|    |_____/____|____/_/   \_\____|
"
" -------- General settings {{{1

set nocompatible                  " do not preserve compatibility with Vi
set modifiable                    " buffer contents can be modified
set encoding=utf-8                " default character encoding
set autoread                      " detect when a file has been modified externally
set spelllang=en,bg               " languages to check for spelling (english, greek)
set spellsuggest=10               " number of suggestions for correct spelling
set updatetime=300                " time of idleness is miliseconds before saving swapfile
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

" vim-signify: default updatetime 4000ms is not good for async update
set updatetime=100

" highlight cursor line
set cursorline
" set cursorcolumn

" set cmdheight=2
set signcolumn=yes

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

map <leader>? :verbose map <CR><CR>

noremap! <C-F> <Right>
noremap! <C-B> <Left>
noremap! <C-D> <Del>

cnoremap <C-A> <HOME>
cnoremap <C-E> <END>
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" Changing window size.
noremap <silent> <S-Left>  :<C-U>wincmd <<CR>
noremap <silent> <S-Right> :<C-U>wincmd ><CR>
noremap <silent> <S-Up>    :<C-U>wincmd -<CR>
noremap <silent> <S-Down>  :<C-U>wincmd +<CR>

" Change current directory of current window.
nnoremap <silent> <Leader>cd :<C-U>cd %:p:h<CR>

" Overwrite the current line with yanked text.
nnoremap <silent> go  pk"_dd

nnoremap '.  :e %:h<C-d>

" -------- Plugins {{{1

" Auto install VimPlug if missing
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/plugged/')

" Appearance
Plug 'chriskempson/base16-vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'morhetz/gruvbox'

" Markdown
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'mzlogin/vim-markdown-toc'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }

" Syntax
Plug 'sheerun/vim-polyglot'

" Git 
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'rhysd/git-messenger.vim'

" Code/text tools
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-surround'
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-commentary'
Plug 'terryma/vim-multiple-cursors'
Plug 'vim-scripts/argtextobj.vim'
Plug 'vim-syntastic/syntastic'
Plug 'majutsushi/tagbar'
Plug 'alvan/vim-closetag'

" File finders
Plug 'junegunn/fzf', { 'dir': '~/.fzf' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/gv.vim'
Plug 'preservim/nerdtree'

" Misc
Plug 'christoomey/vim-tmux-navigator'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-unimpaired'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
" Plug 'lyokha/vim-xkbswitch'

call plug#end()            " required

" Automatically install missing plugins on startup
autocmd VimEnter * 
      \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
      \|   PlugInstall --sync | q
      \| endif

" -------- Coc {{{1

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
" inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Or use `complete_info` if your vim support it, like:
inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current line.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Introduce function text object
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" -------- Appearance {{{1

" enable syntax highlighting
syntax on

" turn hybrid line numbers on
set number relativenumber

" disable relative numbers in insert mode or when the buffer looses focus
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" Default color scheme
colorscheme gruvbox

" set airline theme
let g:airline_theme='gruvbox'
let g:airline#extensions#tabline#enabled = 1

" DEPRECATED: use 'yob' to toggle theme (from unimpaired plugin)
" Switch between dark and light theme using <leader>d and <leader>l respectively
" nnoremap <silent> <leader>dark :set background=dark<CR>
" nnoremap <silent> <leader>light :set background=light<CR>

" Allow for transparent background
" hi Normal guibg=NONE ctermbg=NONE

" needed for proper syntax highlighting in tmux
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors

" -------- Config Reload {{{1

" watch for changes then auto source vimrc
" http://stackoverflow.com/a/2403926
augroup myvimrc
    au!
    au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc,init.vim so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END

" Reload config file manually
" noremap <leader>r :so %<CR>
noremap <leader>reload :so $MYVIMRC<CR>

" -------- Splits {{{1

set splitbelow splitright         " Splits open at the bottom and right, which is non-retarded, unlike vim defaults.

" Ctrl+W + {S,V} split whole screen horizontal/vertical
nnoremap <C-W>S :botright new<CR>
nnoremap <C-W>V :botright vnew<CR>

" -------- Markdown {{{1

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
" set a shortcut for our general wiki index
nmap <silent> <leader>ww :e $HOME/.wiki/Home.md<CR>

" -------- Folding {{{1

" enable folding; http://vim.wikia.com/wiki/Folding
set foldmethod=marker

" fold color
hi Folded cterm=bold ctermfg=DarkBlue ctermbg=none
hi FoldColumn cterm=bold ctermfg=DarkBlue ctermbg=none

" refocus folds; close any other fold except the one that you are on
nnoremap <leader>z zMzvzz

" automatic folding for xml
augroup XML
  autocmd!
  autocmd FileType xml let g:xml_syntax_folding=1
  autocmd FileType xml setlocal foldmethod=syntax fdn=2 fdl=1
  autocmd FileType xml :syntax on
  " autocmd FileType xml :%foldopen!
augroup END

" -------- Aliases {{{1

" Alias for write and quit
nnoremap <leader>wq :wq<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>W :w<CR>

" Alias replace all to S
nnoremap S :%s//g<Left><Left>

" Vertically center document when entering insert mode
autocmd InsertEnter * norm zz

" -------- Motions and Moves {{{1

" keep search matches in the middle of the window.
nnoremap n nzzzv
nnoremap N Nzzzv

" clear matches after search
noremap <silent> ,, :noh<cr>:call clearmatches()<cr>

" Don't move on *
nnoremap * *<c-o>

" shortcuts to prev/next/delete buffer for normal mode
map gn :bn<cr>
map gp :bp<cr>
" map gd :bd<cr>

" When typing jj in insert mode go to normal mode
imap jj <esc>

" -------- Git {{{1

let g:gitgutter_highlight_linenrs = 1

nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
nmap ghs <Plug>(GitGutterStageHunk)
nmap ghu <Plug>(GitGutterUndoHunk)
nmap ghp <Plug>(GitGutterPreviewHunk)

" Remaps git gutter text objects from 'c' (default) to 'h'
omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)

" Mark folding text that there are changes
" Example:
" Default foldtext():         +-- 45 lines: abcdef
" gitgutter#fold#foldtext():  +-- 45 lines (*): abcdef
set foldtext=gitgutter#fold#foldtext()

" git-messenger change of binding - use it 2 times to move focus into popup
" window. Use ? to see options for the popup window.
nmap <C-w>m <Plug>(git-messenger)

" fugitive
nmap <silent> <leader>gg :G<CR>

" -------- Find Tools {{{1

" Also add a custom ProjectFiles command which search only in ~/projects directory.
command! -bang -nargs=? -complete=dir ProjectFiles call fzf#vim#files('~/projects/', <bang>0)
command! -bang -nargs=? -complete=dir DotFiles call fzf#vim#files('~/.dotfiles/', <bang>0)

" Stop default preview window by default. It can be activated manually using <c-?>
let $FZF_DEFAULT_OPTS="--preview-window=hidden"

" Show fuzzy picker for open buffers, recently editted files and files in home tree
nnoremap <silent> <leader>e :Buffers<CR>
nnoremap <silent> <leader>h :History<CR>
nnoremap <silent> <leader>ff :Files<CR>
nnoremap <silent> <leader>fg :GFiles<CR>
nnoremap <silent> <leader>fp :ProjectFiles<CR>
nnoremap <silent> <leader>fd :DotFiles<CR>

" Nerdtree
map <leader>n :NERDTreeToggle<CR>
let NERDTreeWinSize=40
let NERDTreeIgnore=['\.pyc','\~$','\.swo$','\.swp$','\.git$','\.svn','\.idea$',
      \ '\.bzr','\.DS_Store','\.sass-cache','\.vagrant']
let NERDTreeQuitOnOpen=1
let NERDTreeDirArrows=1

" -------- Distraction free mode {{{1

map <silent> <leader>focus :Goyo<CR>

let g:goyo_width = '70%'

autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!

" -------- Keyboard Layout {{{1

" if has("mac")
"   " xkbswitch-macos - https://github.com/myshov/xkbswitch-macosx
"   " link to library goes here
" elseif has("unix")
"   let g:XkbSwitchEnabled = 1
"   let g:XkbSwitchKeymapNames = {'bg(phonetic)' : 'bg', 'en' : 'en'}
"   let g:XkbSwitchLib = '/usr/lib/libxkbswitch.so'

"   let g:XkbSwitchIMappingsTr = {
"             \ 'bg(phonetic)':
"             \ {'<': 'qwertyuiop[]asdfghjkl;''zxcvbnm,.`/'.
"             \       'QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>?~@#$^&|',
"             \  '>': 'явертъуиопшщасдфгхйкл;''зьцжбнм,.ч/'.
"             \       'ЯВЕРТЪУИОПШЩАСДФГХЙКЛ:"ЗѝЦЖБНМ„“?Ч@№$€§Ю'},
"             \ }
" endif

" -------- Syntastic {{{1

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0

let g:syntastic_mode_map = {
      \ "mode": "active",
      \ "active_filetypes": [],
      \ "passive_filetypes": ["java"] }

map <leader>check :SyntasticCheck<CR>

" -------- Tagbar {{{1

nmap <F8> :TagbarToggle<CR>

" -------- Closetag {{{1

" filenames like *.xml, *.html, *.xhtml, ...
" These are the file extensions where this plugin is enabled.
"
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.xml'

" filenames like *.xml, *.xhtml, ...
" This will make the list of non-closing tags self-closing in the specified files.
"
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx,*.xml'

" filetypes like xml, html, xhtml, ...
" These are the file types where this plugin is enabled.
"
let g:closetag_filetypes = 'html,xhtml,phtml,xml'

" filetypes like xml, xhtml, ...
" This will make the list of non-closing tags self-closing in the specified files.
"
let g:closetag_xhtml_filetypes = 'xhtml,jsx,xml'

" integer value [0|1]
" This will make the list of non-closing tags case-sensitive (e.g. `<Link>` will be closed while `<link>` won't.)
"
let g:closetag_emptyTags_caseSensitive = 1

" dict
" Disables auto-close if not in a "valid" region (based on filetype)
"
let g:closetag_regions = {
    \ 'typescript.tsx': 'jsxRegion,tsxRegion',
    \ 'javascript.jsx': 'jsxRegion',
    \ }

" Shortcut for closing tags, default is '>'
"
let g:closetag_shortcut = '>'

" Add > at current position without closing the current tag, default is ''
"
let g:closetag_close_shortcut = '<leader>>'

" -------- Symbol Shortcuts {{{1
" Greek {{{2
map! <C-v>GA Γ
map! <C-v>DE Δ
map! <C-v>TH Θ
map! <C-v>LA Λ
map! <C-v>XI Ξ
map! <C-v>PI Π
map! <C-v>SI Σ
map! <C-v>PH Φ
map! <C-v>PS Ψ
map! <C-v>OM Ω
map! <C-v>al α
map! <C-v>be β
map! <C-v>ga γ
map! <C-v>de δ
map! <C-v>ep ε
map! <C-v>ze ζ
map! <C-v>et η
map! <C-v>th θ
map! <C-v>io ι
map! <C-v>ka κ
map! <C-v>la λ
map! <C-v>mu μ
map! <C-v>xi ξ
map! <C-v>pi π
map! <C-v>rh ρ
map! <C-v>si σ
map! <C-v>ta τ
map! <C-v>ps ψ
map! <C-v>om ω
map! <C-v>ph ϕ

" Math {{{2

map! <C-v>ll →
map! <C-v>hh ⇌
map! <C-v>kk ↑
map! <C-v>jj ↓
map! <C-v>= ∝
map! <C-v>~ ≈
map! <C-v>!= ≠
map! <C-v>!> ⇸
map! <C-v>~> ↝
map! <C-v>>= ≥
map! <C-v><= ≤
map! <C-v>0  °
map! <C-v>ce ¢
map! <C-v>*  •
map! <C-v>co ⌘

