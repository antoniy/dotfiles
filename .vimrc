syntax on

"if has('gui_running')
"  set guifont=Source\ Code\ Pro\ Medium\ 12
"endif

" turn hybrid line numbers on
set number relativenumber
set nu rnu

"set number
"set guioptions-=T
"set guioptions-=r

" General settings
" ----------------
" Read documentation about each option by executing :h <option>

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
"set autoindent                    " indent automatically (useful for formatoptions)
set expandtab                     " use tabs instead of spaces
set tabstop=4                     " tab character width
set shiftwidth=4                  " needs to be the same as tabstop
set smartcase                     " ignore case if the search contains majuscules
set hlsearch                      " highlight all matches of last search
set incsearch                     " enable incremental searching (get feedback as you type)
set backspace=indent,eol,start    " backspace key should delete indentation, line ends, characters
set whichwrap=s,b                 " which motion keys should jump to the above/below wrapped line
"set textwidth=72                  " hard wrap at this column
set joinspaces                    " insert two spaces after puncutation marks when joining multiple lines into one
set wildmenu                      " enable tab completion with suggestions when executing commands
set wildmode=list:longest,full    " settings for how to complete matched strings
set nomodeline                    " vim reads the modeline to execute commands for the current file
set modelines=0                   " how many lines to check in the top/bottom of the file. 0=off
set timeoutlen=1000 ttimeoutlen=0 " timeoutlen is used for mapping delays, ttimoutlen - for key code delays. The purpose of this configuration is to eliminate the delay when we go from visual mode into insert mode.

set clipboard=unnamed         " use system clipboard for copy/paste

filetype off                  " required by Vundle
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'terryma/vim-multiple-cursors'

call vundle#end()            " required
filetype plugin indent on    " required
