
call plug#begin('~/.vim/plugged')

Plug 'williamboman/mason.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'ms-jpq/coq_nvim'
Plug 'ms-jpq/coq.artifacts'

" Plug 'tpope/vim-surround'
Plug 'windwp/nvim-autopairs'

" Plug 'github/copilot.vim'
" Plug 'gentoo/gentoo-syntax' " no mason support

Plug 'ahmedkhalf/project.nvim'
Plug 'scrooloose/nerdtree'

Plug 'vim-airline/vim-airline'
Plug 'ryanoasis/vim-devicons'
Plug 'morhetz/gruvbox'
Plug 'ghifarit53/tokyonight-vim'

call plug#end()

" start plugins
lua require("mason").setup()
lua require("lsp")
lua require("nvim-autopairs").setup()

" start autocompletion
augroup COQ 
        autocmd!
        autocmd VimEnter * COQnow -s
augroup END

