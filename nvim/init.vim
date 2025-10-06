" Configuración básica de Neovim
set number              " Mostrar números de línea
set relativenumber      " Números relativos
set ignorecase          " Ignorar mayúsculas/minúsculas en búsquedas
set smartcase           " Sensible a mayúsculas si la búsqueda las incluye
syntax on               " Habilitar sintaxis
set tabstop=4           " Ancho de tabulación = 4
set shiftwidth=4        " Indentación = 4
set expandtab           " Convertir tabs en espacios
set cursorline          " Resaltar la línea del cursor
set hlsearch            " Resaltar coincidencias de búsqueda
filetype plugin indent on " Detectar tipo de archivo y cargar configs específicas
set smartindent         " Indentación automática

" ==========================
" Gestor de plugins: vim-plug
" ==========================
call plug#begin('~/.local/share/nvim/plugged')

" Tema Cyberdream
Plug 'scottmckendry/cyberdream.nvim'

" Resaltado de sintaxis moderno
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Gestor de LSP servers (Mason)
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'  " Para auto-configurar LSPs instalados con Mason

" Configuración de LSP
Plug 'neovim/nvim-lspconfig'

" Autocompletado con nvim-cmp
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'

" Snippets con LuaSnip
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'

" Debugging con DAP
Plug 'mfussenegger/nvim-dap'
Plug 'mfussenegger/nvim-dap-python'

" Usar nnn
Plug 'luukvbaal/nnn.nvim'

" otros
Plug 'jose-elias-alvarez/null-ls.nvim'    " Para integrar ruff, shellcheck, shfmt como linters/formatters

call plug#end()

" ==========================
" Configuración de plugins (en Lua)
" ==========================

" Configuración de Treesitter
lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "python", "bash", "json", "yaml" },
  highlight = { enable = true },
  indent = { enable = true },
}
EOF

" Configuración de Mason (gestor de LSP servers)
lua << EOF
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "pyright", "bashls" },  -- Asegura que se instalen si faltan
})
EOF
" Configuración de LSP y servidores (Pyright para Python, bashls para Bash)
lua << EOF
-- Función on_attach común
local on_attach = function(client, bufnr)
  local opts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)      -- Ir a definición
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)            -- Mostrar hover/info
  vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, opts)   -- Formatear (usa ruff si configurado)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)  -- Renombrar
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)  -- Acciones de código
end

-- Pyright para Python (integra ruff para linting/formateo)
vim.lsp.config('pyright', {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",  -- Ajusta según tus necesidades: off, basic, strict
      },
    },
  },
  on_attach = on_attach,
})
vim.lsp.enable('pyright')

-- bash-language-server para Bash (integra shellcheck y shfmt)
vim.lsp.config('bashls', {
  on_attach = on_attach,
})
vim.lsp.enable('bashls')
EOF

" Configuración de nvim-cmp (autocompletado)
lua << EOF
local cmp = require'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),  -- Aceptar con Enter
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  })
}
EOF

" Configuración de DAP para debugging Python
lua << EOF
require('dap-python').setup('~/.venvs/dev/bin/python3')
-- Mapeos básicos para debugging
vim.keymap.set('n', '<F6>', require'dap'.continue)       -- Continuar/Empezar debug
vim.keymap.set('n', '<F7>', require'dap'.step_over)      -- Step over
vim.keymap.set('n', '<F8>', require'dap'.step_into)      -- Step into
vim.keymap.set('n', '<leader>b', require'dap'.toggle_breakpoint)  -- Toggle breakpoint
EOF

" ruff, shellcheck y shfmt
lua << EOF
local null_ls = require("null-ls")
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
null_ls.setup({
  sources = {
    -- Python: ruff para linting y formateo
    null_ls.builtins.diagnostics.ruff,
    null_ls.builtins.formatting.ruff,
    -- Bash: shellcheck para linting, shfmt para formateo
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.formatting.shfmt.with({
      extra_args = { "-i", "4" },  -- Indentación de 4 espacios, como tu config
    }),
  },
  -- Formateo automático al guardar
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end
  end,
})
EOF


" ==========================
" Otras configuraciones
" ==========================
" Tema
colorscheme cyberdream

" Ejecutar Python rápidamente
nnoremap <F5> :w<CR>:!python3 %<CR>

" Salir de modo terminal con Ctrl+Space
tnoremap <C-Space> <C-\><C-n>

" lua para nnn
lua << EOF
require("nnn").setup({
  explorer = {
    cmd = "nnn -de",  -- Comando para abrir nnn
    width = 30,       -- Ancho del split
    side = "botright", -- Posición (o vsplit para vertical)
  },
  picker = {
    cmd = "nnn -dep -",  -- Modo picker
    style = { border = "single" },
  },
  mappings = {
    { "<C-t>", require("nnn").builtin.open_in_tab },  -- Abrir en tab
  },
})
EOF
