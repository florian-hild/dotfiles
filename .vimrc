"-------------------------------------------------------------------------------
" Author     : Florian Hild
" Created    : 29-07-2022
" Description: Vim config
"-------------------------------------------------------------------------------

" This is redundant, but explicit settings over implicit/default behavior
set nocompatible

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Load an indent file for the detected file type.
filetype indent on

" Turn syntax highlighting on.
syntax on

" Add numbers to each line on the left-hand side.
set number
set relativenumber

" Highlight cursor line underneath the cursor horizontally.
set cursorline

" Set color schema
colorscheme desert

" Highlight cursor line underneath the cursor vertically.
set nocursorcolumn

" New lines inherit the indentation of previous lines
set autoindent

" When shifting lines, round the indentation to the nearest multiple of “shiftwidth.”
set shiftround

set smartindent

set softtabstop=4

" Set shift width to 4 spaces.
set shiftwidth=4

" Set tab width to 4 columns.
set tabstop=4

" Use space characters instead of tabs.
set expandtab

" Do not let cursor scroll below or above N number of lines when scrolling.
set scrolloff=10

" Do not wrap lines. Allow long lines to extend as far as the line goes.
set nowrap

" Avoid wrapping a line in the middle of a word.
set linebreak

" While searching though a file incrementally highlight matching characters as you type.
set incsearch

" Ignore capital letters during search.
set ignorecase

" Insert “tabstop” number of spaces when the “tab” key is pressed
set smarttab

" Override the ignorecase option if searching for capital letters.
" This will allow you to search specifically for capital letters.
set smartcase

" Show partial command you type in the last line of the screen.
set showcmd

" Show the mode you are on the last line.
set showmode

" Show matching words during a search.
set showmatch

" Use highlighting when doing a search.
set hlsearch

" Set the commands to save in history default number is 20.
set history=1000

" Don’t update screen during macro and script execution.
set lazyredraw

" less than 1000 for no delay at new line above
set timeoutlen=500

" Enable auto completion menu after pressing TAB.
set wildmenu

" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest

" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" Use an encoding that supports unicode.
set encoding=utf-8 fileencodings=utf-8

" Always display the status bar.
set laststatus=2

" Always show cursor position
set ruler

" Disable beep on errors.
set noerrorbells

" Set the window’s title, reflecting the file currently being edited.
set title

" Use colors that suit a dark background.
set background=dark

" Keep syntax while inserting
set copyindent

" Fold based on indention levels.
set foldmethod=indent

" Only fold up to three nested levels.
set foldnestmax=3

" Disable folding by default.
set nofoldenable

" Enable spellchecking.
set nospell

" Allow backspacing over indention, line breaks and insertion start.
set backspace=indent,eol,start

augroup configgroup
  autocmd!

  " Always clear highlite
  autocmd VimEnter * highlight clear SignColumn

  " save/write in VIM I want to trim trailing whitespace and ensure that the file's line endings are UNIX and not DOS
  autocmd BufWritePre,FileWritePre * :%s/\s\+$//e | %s/\r$//e

  autocmd FileWritePre *.pl,*.pm,*.yml,*.sh
    \:call <SID>StripTrailingWhitespaces()

  " Use template
  autocmd bufnewfile *.pl 0r ~/.vim/pl_header.temp
  autocmd bufnewfile *.pm 0r ~/.vim/pm_header.temp
  autocmd bufnewfile *.yml 0r ~/.vim/yml_header.temp
  autocmd bufnewfile *.yaml 0r ~/.vim/yml_header.temp
  autocmd bufnewfile *.sh 0r ~/.vim/sh_header.temp
  autocmd bufnewfile *.py 0r ~/.vim/py_header.temp

  " set tabstop
  autocmd FileType css        setlocal sw=2 sts=2 ts=2 et
  autocmd FileType html       setlocal sw=2 sts=2 ts=2 et
  autocmd FileType htmldjango setlocal sw=2 sts=2 ts=2 et
  autocmd FileType javascript setlocal sw=2 sts=2 ts=2 et
  autocmd FileType json       setlocal sw=2 sts=2 ts=2 et
  autocmd FileType ruby       setlocal sw=2 sts=2 ts=2 et
  autocmd FileType scss       setlocal sw=2 sts=2 ts=2 et
  autocmd FileType yaml       setlocal sw=2 sts=2 ts=2 et
  autocmd FileType php        setlocal sw=4 sts=4 ts=4 et
  autocmd FileType python     setlocal sw=4 sts=4 ts=4 et tw=88 cc+=72
augroup END

" turn off search highlight mit leertaste
nnoremap <leader><space> :nohlsearch<CR>

" center screen after moving half page down and up
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz

" Center search findings
nnoremap n nzzzv
nnoremap N Nzzzv

" allows cursor change in tmux mode
" These lines change the cursor from block cursor mode to vertical bar cursor mode when using tmux.
if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif
