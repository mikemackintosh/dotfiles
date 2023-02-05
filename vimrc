call plug#begin()

" Plugins
Plug 'junegunn/vim-easy-align'

" Themes
Plug 'drewtempelmeyer/palenight.vim'
Plug 'joshdick/onedark.vim'

" Languages
Plug 'fatih/vim-go', { 'tag': '*' }
Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }


" On-demand loading
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

call plug#end()


set background=dark
colorscheme palenight