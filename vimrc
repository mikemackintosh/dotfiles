call plug#begin()

" Plugins
Plug 'junegunn/vim-easy-align'

" Themes
Plug 'drewtempelmeyer/palenight.vim'
Plug 'joshdick/onedark.vim'

" Languages
Plug 'fatih/vim-go', { 'tag': '*' }
Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

Plug 'tpope/vim-surround'
Plug 'airblade/vim-gitgutter'

" On-demand loading
Plug 'preservim/nerdtree'

Plug 'itchyny/lightline.vim'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-commentary'

Plug 'ctrlpvim/ctrlp.vim'

call plug#end()

" Status line

set termguicolors
let &t_8f = "\<Esc>[38:2:%lu:%lu:%lum"
let &t_8b = "\<Esc>[48:2:%lu:%lu:%lum"

let g:lightline = { 'colorscheme': 'palenight' }
let g:airline_theme = "palenight"
let g:palenight_terminal_italics = 1

let g:airline#extensions#tabline#enabled = 1

 let g:ctrlp_map = '<c-p>'
 let g:ctrlp_cmd = 'CtrlP'

set number
set background=dark
colorscheme palenight
hi Normal guibg=NONE ctermbg=NONE


autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * NERDTree | if argc() > 0 || exists("s:std_in") | wincmd p | endif
