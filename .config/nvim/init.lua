-- Vanilla Config
-- require('impatient')
require('jimi.settings')
require('jimi.autocmd')
--require('jimi.colorscheme')
require('jimi.plugins')
require('jimi.keybinds')
require('jimi.cmp')
--require('jimi.vimtex')
require('jimi.nvim-tree')
--require('jimi.vimwiki')
require('jimi.telescope')
--require('jimi.treesitter')
--require('jimi.autopairs')
--require('jimi.comment')
--require('jimi.gitsigns')
--require('jimi.illuminate')
require('jimi.toggleterm')
--require('jimi.lualine')
require('jimi.iron')
require('jimi.satellite')
require('jimi.lsp')

---Pretty print lua table
function _G.dump(...)
    local objects = vim.tbl_map(vim.inspect, { ... })
    print(unpack(objects))
end

-- Settings for vim plugin that don't work from lua files

-- Vimtex
vim.g.tex_flavor = 'latex'
vim.g.vimtex_view_method = 'skim'
vim.g.vimtex_quickfix_mode = 0        -- fixed typo (was vimte_quickfix_mode)
vim.o.conceallevel = 1
vim.g.tex_conceal = ''
vim.g.vimtex_compiler_method = 'latexmk'

-- Vimwiki
vim.cmd("filetype plugin on")
vim.g.vimwiki_global_ext = 0
vim.g.vimwiki_list = {{
    auto_export = 1,
    auto_header = 1,
    automatic_nested_syntaxes = 1,
    path = "~/Google\\ Drive/Work/Notes/vimwiki",
    path_html = "~/Google\\ Drive/Work/Notes/vimwiki_html",
    template_path = "~/.dotfiles/vimwiki_conf/templates_html",
    template_default = "GitHub",
    template_ext = ".html5",
    syntax = "markdown",
    ext = ".md",
    custom_wiki2html = "~/Google\\ Drive/Work/Notes/vimwiki/wiki2html_zsh.sh",
    autotags = 1,
    list_margin = 0,
    links_space_char = "_",
    }}
vim.g.vimwiki_folding=""
vim.g.vimwiki_hl_headers = 1
vim.g.vimwiki_ext2syntax = {[".md"] = "markdown"}
