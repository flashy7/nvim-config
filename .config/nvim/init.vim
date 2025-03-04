syntax on
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
" set expandtab
set noexpandtab
set smartindent
set nu
set ic
set nowrap
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
" set relativenumber
set clipboard+=unnamedplus
set nohlsearch
set noshowmode
set completeopt=menu,menuone,noselect
set termguicolors
set shortmess+=c
set background=dark
set mouse=a
set list

call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdcommenter'
" Plug 'miyakogi/seiya.vim' " Enables transparency
Plug 'rhysd/vim-clang-format'

Plug 'mattn/vim-goimports'
Plug 'simrat39/rust-tools.nvim'

" Neovim v0.5 plugins
Plug 'kyazdani42/nvim-web-devicons'
Plug 'nvim-lua/plenary.nvim' " Needed for gitsigns and telescope
Plug 'lewis6991/gitsigns.nvim' " Like git gutter
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/popup.nvim' " Needed for telescope
Plug 'nvim-telescope/telescope.nvim' " Fuzzy finder
Plug 'norcalli/nvim-colorizer.lua' " Colorizes RGB color codes
Plug 'kyazdani42/nvim-tree.lua'
Plug 'hoob3rt/lualine.nvim'
Plug 'glepnir/dashboard-nvim'
Plug 'kyazdani42/nvim-tree.lua'
Plug 'Mofiqul/vscode.nvim'
Plug 'windwp/nvim-autopairs'
Plug 'petertriho/nvim-scrollbar'
Plug 'andweeb/presence.nvim'

" These deal with autocompletions and diagnostics
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/nvim-cmp'
Plug 'ray-x/lsp_signature.nvim'
Plug 'L3MON4D3/LuaSnip'
Plug 'mattn/efm-langserver'
" Plug 'creativenull/efmls-configs-nvim'

Plug 'kyazdani42/nvim-web-devicons'
" Plug 'folke/trouble.nvim'

call plug#end()

lua <<EOF
require('nvim-treesitter.configs').setup { highlight = { enable = true }}
require('gitsigns').setup()
require('telescope').setup()
require('nvim-autopairs').setup{}
require('nvim-tree').setup()
require("presence"):setup({
	auto_update         = true,                       -- Update activity based on autocmd events (if `false`, map or manually execute `:lua package.loaded.presence:update()`)
    neovim_image_text   = "Neovim",					  -- Text displayed when hovered over the Neovim image
    main_image          = "neovim",                   -- Main image display (either "neovim" or "file")
    log_level           = nil,                        -- Log messages at or above this level (one of the following: "debug", "info", "warn", "error")
    debounce_timeout    = 10,                          -- Number of seconds to debounce events (or calls to `:lua package.loaded.presence:update(<filename>, true)`)
    enable_line_number  = false,                      -- Displays the current line number instead of the current project
    buttons             = false,                       -- Configure Rich Presence button(s), either a boolean to enable/disable, a static table (`{{ label = "<label>", url = "<url>" }, ...}`, or a function(buffer: string, repo_url: string|nil): table)
})
require("scrollbar").setup({
	handle = {
        color = "#343434",
    },
})

require('lualine').setup{
    options = {
        theme = 'vscode',
        section_separators = {},
    },
}

-- LSP Config setup
local nvim_lsp = require('lspconfig')

vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', 'K', vim.lsp.buf.hover)

local on_attach = function(client, bufnr)
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
end

require('lsp_signature').setup({
    bind = true,
    fix_pos = true,
    handler_opts = { border = "none" },
    always_trigger = true,
    hint_enable = false,
})

local cmp = require('cmp')
local cmp_autopairs = require('nvim-autopairs.completion.cmp')

cmp.setup({
    snippet = {
      expand = function(args)
         require('luasnip').lsp_expand(args.body)
      end,
    },
    mapping = {
        ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<Down>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ['<Up>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ['<Tab>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
        }),
    },
    sources = {
        { name = 'nvim_lsp' },
        { name = 'buffer' },
    }
})
cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done({  map_char = { tex = '' } }))

-- require("trouble").setup{
--     auto_open = true,
--     auto_close = true,
-- }

local shellcheck = {
    lintCommand = "shellcheck -f gcc -x -",
    lintStdin = true,
    lintFormats = {"%f:%l:%c: %trror: %m", "%f:%l:%c: %tarning: %m", "%f:%l:%c: %tote: %m"},
}

local shfmt = {
    formatCommand = 'shfmt -ci -s -sr -i 2',
    formatStdin = true,
}

nvim_lsp["efm"].setup({
    init_options = {
        documentFormatting = true,
        hover = false,
        documentSymbol = false,
        codeAction = false,
        completion = false,
    },
    settings = {
        rootMarkers = { "package.json", "pyproject.toml", "Cargo.toml", ".git/" },
        languages = {
            sh = { shellcheck },
        },
    },
})

nvim_lsp["eslint"].setup({
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end
})

local servers = { "pyright", "gopls", "tsserver" }
for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
        on_attach = on_attach,
        capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
        flags = {
            debounce_text_changes = 500,
        },
    }
end

local rt = require("rust-tools")

rt.setup({
  server = {
	on_attach = on_attach,
  },
})
EOF

let g:vscode_style = "dark"

colorscheme vscode

let g:dashboard_default_executive = 'telescope'
let g:dashboard_custom_header = [
\ ' ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
\ ' ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
\ ' ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
\ ' ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
\ ' ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
\ ' ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
\]

" Nvim transparency
let g:seiya_auto_enable = 1
let g:seiya_target_groups = has('nvim') ? ['guibg'] : ['ctermbg']

" Spell check toggle on F6
map <F6> :setlocal spell! spelllang=en_us<CR>
map <F5> :setlocal spell! spelllang=de<CR>
map <F7> :set nowrap!<CR>

" Ale
" let g:ale_linters = {'go': ['revive', 'staticcheck', 'govet']}

nnoremap j gj
nnoremap k gk
inoremap jj <ESC>

nnoremap <SPACE> <Nop>
let mapleader=" "
nnoremap <leader>d "_d
xnoremap <leader>d "_d

map <C-_> <plug>NERDCommenterToggle
nnoremap <C-n> :NvimTreeToggle<CR>
let g:NERDSpaceDelims = 1
let g:NERDDefaultAlign = 'left'

filetype plugin on

" Find files using Telescope command-line sugar.
nnoremap ff <cmd>Telescope find_files<cr>
nnoremap fg <cmd>Telescope live_grep<cr>
nnoremap fd <cmd>Telescope diagnostics<cr>
nnoremap fc <cmd>Telescope git_commits<cr>
nnoremap fC <cmd>Telescope git_bcommits<cr>
nnoremap fb <cmd>Telescope git_branches<cr>
nnoremap fv <cmd>Telescope git_status<cr>
nnoremap fs <cmd>Telescope git_stash<cr>

" Nvim tree stuff
let g:nvim_tree_special_files = {}
let g:nvim_tree_ignore = [ '.git', 'node_modules', '.cache', '.vscode' ]

" Stops yanking when pasting in visual mode
vnoremap p pgvy

" Ctrl+S to save
noremap <silent> <C-S>          :update<CR>
vnoremap <silent> <C-S>         <C-C>:update<CR>
inoremap <silent> <C-S>         <C-O>:update<CR>

" Git blame
nnoremap <C-K> :Gitsigns toggle_current_line_blame<CR>
nnoremap U :Gitsigns reset_hunk<CR>

autocmd BufWritePre *.cpp :ClangFormat
autocmd FileType sh setlocal tabstop=2 softtabstop=2 shiftwidth=2

autocmd FileType vue setlocal tabstop=2 expandtab shiftwidth=2
autocmd FileType typescript setlocal tabstop=2 expandtab shiftwidth=2
autocmd FileType javascript setlocal tabstop=2 expandtab shiftwidth=2
