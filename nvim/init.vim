"Numeración de línea
set number
set relativenumber
"Mejorar busqueda
set ignorecase
set smartcase
"Sintaxis
syntax on
"Indentacion
set tabstop=4
set shiftwidth=4
set expandtab
"Resaltar
set cursorline        " Resalta la línea donde está el cursor
set hlsearch          " Resalta todas las coincidencias de la búsqueda

"Otras cosas
filetype plugin on " detecta el tipo de archivo y carga configs específicas

" ==========================
" Gestor de plugins: vim-plug
" ==========================
call plug#begin('~/.vim/plugged')

" Tema Cyberdream
Plug 'scottmckendry/cyberdream.nvim'

" Colores y sintaxis mejorada
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Autocompletado para Python
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

filetype plugin indent on
"Ejecutar rapido python
nnoremap <F5> :w<CR>:!python3 %<CR>
"Colores
colorscheme cyberdream 
"chatgpt
" ==========================
" Configuración básica Neovim
" ==========================
set tabstop=4           " ancho de tabulación = 4
set shiftwidth=4        " identación = 4
set expandtab           " convierte tab en espacios
set smartindent         " indentación automática

" ==========================
" Configuración de plugins
" ==========================


" Treesitter: mejor resaltado de sintaxis
lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "python", "bash", "json", "yaml" },
  highlight = { enable = true },
}
EOF

" COC (autocompletado y LSP)
" Usar <Tab> para moverte entre sugerencias
inoremap <silent><expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"

" Atajo para formatear con Coc
nmap <leader>f  :call CocAction('format')<CR>
" Mapear Ctrl+space para salir de terminal
tnoremap <C-space> <C-\><C-n>

" Para autocompletar más fácil con Coc
" TAB: si el popup está visible y solo hay 1 opción -> confirmar,
" si hay varias -> mover al siguiente, si no -> insertar tab.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? (get(coc#pum#info(), 'size', 0) == 1 ? coc#pum#select_confirm() : coc#pum#next(1)) :
      \ "\<TAB>"

inoremap <silent><expr> <S-TAB>
      \ coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

