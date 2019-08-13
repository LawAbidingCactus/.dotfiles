"vim needs a more posix-compatible shell than fish
if &shell =~# 'fish$'
    "from vim-sensible
    set shell=/usr/bin/env\ bash
endif

"autoinstall plug
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"dependencies:
"generic:
"python for neovim? (pip3 install --user --upgrade pynvim)
"universal-ctags (pull from git repo, build and install in $PATH)
"ripgrep (sudo dnf install ripgrep)
"language-specific:
"rust:
"rust (curl https://sh.rustup.rs -sSf | sh)
"rls (rustup component add rls rust-analysis rust-src)
"rustfmt (rustup component add rustfmt)
"ctags (compile/install from source)
"racket/sicp:
"download racket from racket-lang.org
"use ddg, idk
"haskell:
"hie
"install stack then follow source install instructions on github
"install hfmt and all of hfmt fixers

call plug#begin()

Plug 'justinmk/vim-sneak'

Plug 'morhetz/gruvbox'

Plug 'dense-analysis/ale'

Plug 'vim-airline/vim-airline'

Plug 'ervandew/supertab'

Plug 'mbbill/undotree'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }

Plug 'junegunn/fzf.vim'

Plug 'tpope/vim-commentary'

Plug 'tpope/vim-surround'

Plug 'tpope/vim-repeat'

Plug 'dag/vim-fish'

Plug 'vimwiki/vimwiki'

Plug 'junegunn/rainbow_parentheses.vim'

Plug 'wlangstroth/vim-racket'

Plug 'airblade/vim-gitgutter'

Plug 'majutsushi/tagbar'

Plug 'tpope/vim-fugitive'

Plug 'rust-lang/rust.vim'

Plug 'neovimhaskell/haskell-vim'

call plug#end()

"note: there's no need to create an alternative escape-- alt+space will
"already do this (alt+char creates terminal escape code that executes
"<esc> + <char>)

"make vim extremely responsive without destroying ssd with writes
"(might mess with cursorhold?)
set updatetime=0
set directory=/dev/shm/nvim_swap//

function Gdrive_sync(timer)
    call jobstart('rclone sync /dev/shm/nvim_swap/ gdrive:/nvim_swap/')
endfunction

function Rclone_dedupe(timer)
    call jobstart('rclone dedupe skip "gdrive:/nvim_swap/"')
endfunction

function Fs_sync(timer)
    call jobstart('rsync -avu --delete "/dev/shm/nvim_swap/" "/home/user/.local/share/nvim/swap"')
endfunction

if executable('rclone')
    let timer = timer_start(1000, 'Gdrive_sync', {'repeat': -1})
    let timer = timer_start(1000, 'Rclone_dedupe', {'repeat': -1})
else
    let timer = timer_start(1000, 'Fs_sync', {'repeat': -1})
endif

"disable modelines (security)
set nomodeline

"leader key
let mapleader = " "

"localleader key; '\\' must be used because '\' functions as escape char
let maplocalleader = "\\"

"line numbers
set number

"scroll context (note that for set <var>=<mode>, there must be not be spaces on
"either side of the equal sign)
set scrolloff=5

"move preview window to bottom (less intrusive)
set splitbelow

"make cursor more visible"
set cursorline

"toggle highlighting for searches
set hlsearch!
nnoremap <silent><leader>/ :set hlsearch!<CR>

"tab settings
set expandtab
set tabstop=4
set shiftwidth=4

" automatically close things
inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O
" skip past inserted characters
inoremap <C-s> <C-o>A

" special symbols
inoremap \forall ∀
inoremap \to →
inoremap \lambda λ
inoremap \Sigma Σ
inoremap \exists ∃
inoremap \equiv ≡

"last position jump
au BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g`\""
  \ | endif

"esc returns to normal in terminal
"note: use alt + j or something similar to switch to normal mode in fish
tnoremap <Esc> <C-\><C-n>

"toggle terminal
let s:term_buf = 0
let s:term_win = 0

function! Term_toggle(height)
    if win_gotoid(s:term_win)
        hide
    else
        new terminal
        exec "resize ".a:height
        try
            exec "buffer ".s:term_buf
            exec "bd terminal"
        catch
            call termopen($SHELL, {"detach": 0})
            let s:term_buf = bufnr("")
            setlocal nocursorline "signcolumn=no
        endtry
        startinsert!
        let s:term_win = win_getid()
    endif
endfunction

nnoremap <silent><M-t> :call Term_toggle(10)<CR>
inoremap <silent><M-t> <ESC>:call Term_toggle(10)<CR>
tnoremap <silent><M-t> <C-\><C-n>:call Term_toggle(10)<CR>

"theming
set termguicolors
set background=dark
let g:gruvbox_contrast_dark = 'medium'
colorscheme gruvbox

"persistent undo and undo tree config (not necessary to specify undodir)
set undofile
let g:undotree_WindowLayout = 3
let g:undotree_ShortIndicators = 1
let g:undotree_HighlightChangedText = 0
let g:undotree_HelpLine = 0
let g:undotree_SetFocusWhenToggle = 1
nnoremap <leader>u :UndotreeToggle<CR>

"enable jumping to hints
let g:sneak#label = 1

"ALE config
let g:ale_completion_enabled = 1
let g:ale_fix_on_save = 1
let g:ale_linters = {
    \ 'rust': ['rls'],
    \ 'haskell': ['hie'],
    \ }
let g:ale_fixers = {
    \ '*': ['remove_trailing_lines', 'trim_whitespace'],
    \ 'rust': ['rustfmt'],
    \ 'haskell': ['hfmt'],
    \ }
let g:ale_rust_rls_toolchain = 'stable'
let g:ale_haskell_hie_executable = 'hie-wrapper'

"fzf config
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fb :BLines<CR>
nnoremap <leader>fl :Lines<CR>
nnoremap <leader>ft :BTags<CR>
nnoremap <leader>fp :Tags<CR>
nnoremap <leader>fm :Marks<CR>
nnoremap <leader>fc :Commands<CR>
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --hidden --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" airline configuration
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.notexists = '!'
let g:airline#extensions#hunks#enabled = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9
nmap <leader>- <Plug>AirlineSelectPrevTab
nmap <leader>= <Plug>AirlineSelectNextTab

"tagbar config
nnoremap <leader>t :TagbarToggle<CR>
let g:rust_use_custom_ctags_defs = 1  " if using rust.vim
let g:tagbar_type_rust = {
  \ 'ctagsbin' : '/home/user/.local/bin/ctags',
  \ 'ctagstype' : 'rust',
  \ 'kinds' : [
      \ 'n:modules',
      \ 's:structures:1',
      \ 'i:interfaces',
      \ 'c:implementations',
      \ 'f:functions:1',
      \ 'g:enumerations:1',
      \ 't:type aliases:1:0',
      \ 'v:constants:1:0',
      \ 'M:macros:1',
      \ 'm:fields:1:0',
      \ 'e:enum variants:1:0',
      \ 'P:methods:1',
  \ ],
  \ 'sro': '::',
  \ 'kind2scope' : {
      \ 'n': 'module',
      \ 's': 'struct',
      \ 'i': 'interface',
      \ 'c': 'implementation',
      \ 'f': 'function',
      \ 'g': 'enum',
      \ 't': 'typedef',
      \ 'v': 'variable',
      \ 'M': 'macro',
      \ 'm': 'field',
      \ 'e': 'enumerator',
      \ 'P': 'method',
  \ },
\ }

" rainbow parenthesis config (for lisp)
augroup rainbow_lisp
    autocmd!
    autocmd FileType lisp,clojure,scheme RainbowParentheses
augroup END

" haskell-vim configuration
let g:haskell_enable_quantification = 1
let g:haskell_enable_recursivedo = 1
let g:haskell_enable_arrowsyntax = 1
let g:haskell_enable_pattern_synonyms = 1
let g:haskell_enable_typeroles = 1
let g:haskell_enable_static_pointers = 1
let g:haskell_backpack = 1
