
" share system clipboard
set clipboard+=unnamedplus

" going	through	line breaks with hjkl and <- ->
set whichwrap+=<,>,h,l,[,]

" Scrolling with Ctrl + j/k
nnoremap <C-k> <C-y>
nnoremap <C-j> <C-e>

" Scrolling with Ctrl + Up/Down arrow keys
nnoremap <C-Up> <C-y>
nnoremap <C-Down> <C-e>

" quickly configurate vim
function! VmConfComplete(ArgLead, ...)
    let base_path = expand('~/.config/nvim/')
    let pattern = base_path . a:ArgLead . '*'

    let full_paths = glob(pattern, 0, 1)
    return map(full_paths, "substitute(v:val, '^' . escape(base_path, '\'), '', '')")
endfunction

command! Reload source $MYVIMRC
command! -nargs=1 -complete=customlist,VmConfComplete VmConf vnew | edit ~/.config/nvim/<args>
