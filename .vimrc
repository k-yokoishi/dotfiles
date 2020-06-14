set number
set noswapfile
set ruler
set hlsearch
set tabstop=4
set ignorecase
set smartcase

syntax enable

set background=dark
colorscheme jellybeans

let mapleader = "\<Space>"

nnoremap W :w<CR>
nnoremap Q :q<CR>
nnoremap <C-n> :noh<CR>
nnoremap L $
nnoremap H 0
nnoremap x "_x
nnoremap [ %

inoremap <silent> jj <ESC>

" visual-star
xnoremap * :<C-u>call <SID>VSetSearch()<CR>/<CR>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch()<CR>?<CR>=@/<CR><CR>

function!s:VSetSearch()
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, '/\'), '\n', '\\n', 'g')
  let @s = temp
endfunction

