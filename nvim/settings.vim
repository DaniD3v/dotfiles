
colorscheme tokyonight

filetype on
filetype plugin on

set number
set nowrap

set expandtab
set tabstop=4
set shiftwidth=4

set incsearch
set wildmenu
set wildmode=list:longest
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" disable language provider support (lua and vimscript plugins only)
let g:loaded_perl_provider = 0
let g:loaded_ruby_provider = 0
let g:loaded_node_provider = 0
let g:loaded_python_provider = 0
let g:loaded_python3_provider = 0
