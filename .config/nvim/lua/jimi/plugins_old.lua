local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = fn.system({
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
    })
    print("Installing packer close and reopen Neovim...")
    vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end


-- Automatically run :PackerCompile whenever plugins.lua is updated with an autocommand:
vim.api.nvim_create_autocmd('BufWritePost', {
    group = vim.api.nvim_create_augroup('PACKER', { clear = true }),
    pattern = 'plugins.lua',
    command = 'source <afile> | PackerCompile',
})

return packer.startup({
    function(use)

        -- Package Manager --
        use('wbthomason/packer.nvim')

        -- Required plugin with lua functions
        use('nvim-lua/plenary.nvim')

        -- My plugins
        use "lewis6991/impatient.nvim"
        use "lervag/vimtex"  -- latex support
        use "vimwiki/vimwiki"  -- vimwiki
--        use "windwp/nvim-autopairs"  -- Autopairs, integrates with both cmp and treesitter
        use({
            'numToStr/Comment.nvim',  -- making comments
            event = 'BufRead',
            config = function()
                require('jimi.comment')
            end,
        })
        use({
            "akinsho/toggleterm.nvim",  -- terminal in neovim
            event = 'CursorHold',
            config = function()
                require('jimi.toggleterm')
            end,
        })
        use({
            'norcalli/nvim-colorizer.lua',
            event = 'CursorHold',
            config = function()
                require('colorizer').setup()
            end,
        })


        -- cmp plugins
        --[[ use "hrsh7th/nvim-cmp" -- The completion plugin ]]
        --[[ use "hrsh7th/cmp-buffer" -- buffer completions ]]
        --[[ use "hrsh7th/cmp-path" -- path completions ]]
        --[[ use "hrsh7th/cmp-cmdline" -- cmdline completions ]]
        --[[ use "saadparwaiz1/cmp_luasnip" -- snippet completions ]]
        --[[ use "hrsh7th/cmp-nvim-lsp" ]]
        --[[ use "hrsh7th/cmp-nvim-lua" ]]

        -- snippets
        --[[ use "L3MON4D3/LuaSnip" --snippet engine ]]
        --[[ use "rafamadriz/friendly-snippets" -- a bunch of snippets to use ]]

        -- LSP

        use({
            {
            'neovim/nvim-lspconfig',
            event = 'BufRead',
            config = function()
                require('jimi.lsp')
            end,
            requires = {
                {
                    -- WARN: Unfortunately we won't be able to lazy load this
                    'hrsh7th/cmp-nvim-lsp',
                },
            },
            }, -- TODO: why mason doesn't work with 'after'?
            { "williamboman/mason.nvim"},-- after = 'nvim-lspconfig' },
            { "williamboman/mason-lspconfig.nvim"}--, after = 'nvim-lspconfig' },
            --[[ { "RRethy/vim-illuminate", ]]
            --[[     after = 'nvim-lspconfig', ]]
            --[[     config = function () ]]
            --[[         require('jimi.illuminate') ]]
            --[[     end ]]
            --[[ }, ]]
        })

        use({
            {
                'hrsh7th/nvim-cmp',
                event = 'InsertEnter',
                config = function()
                    require('jimi.cmp')
                end,
                requires = {
                    {
                        'L3MON4D3/LuaSnip',
                        event = 'InsertEnter',
                        config = function()
                            require('jimi.cmp')
                        end,
                        requires = {
                            {
                                'rafamadriz/friendly-snippets',
                                event = 'CursorHold',
                            },
                        },
                    },
                },
            },
            { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' },
            { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
            { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
            { 'hrsh7th/cmp-cmdline', after = 'nvim-cmp' },
            { 'hrsh7th/cmp-nvim-lua', after = 'nvim-cmp' },
        })

        -- NOTE: nvim-autopairs needs to be loaded after nvim-cmp, so that <CR> would work properly
        use({
            'windwp/nvim-autopairs',
            event = 'InsertCharPre',
            after = 'nvim-cmp',
            config = function()
                require('jimi.autopairs')
            end,
        })



        --[[ use "neovim/nvim-lspconfig" -- enable LSP ]]
        --[[ use "williamboman/mason.nvim" ]]
        --[[ use "williamboman/mason-lspconfig.nvim" ]]
        --[[ use "RRethy/vim-illuminate" ]]
        -- use "jose-elias-alvarez/null-ls.nvim" -- for formatters and linters

        -- Theme, Icons, Statusbar, Bufferbar --
        use 'nvim-tree/nvim-web-devicons'
        use({
            'RRethy/nvim-base16',
            config = function()
                require('jimi.colorscheme')
            end,
        })
        use({
                'nvim-lualine/lualine.nvim',
                after = 'nvim-base16',
                event = 'BufEnter',
                config = function()
                    require('jimi.lualine')
                end,
        })

        -- Treesitter: Better Highlights --
        use({
            {
                'nvim-treesitter/nvim-treesitter',
                event = 'CursorHold',
                run = ':TSUpdate',
                config = function()
                    require('jimi.treesitter')
                end,
            },
            { 'nvim-treesitter/nvim-treesitter-refactor', after = 'nvim-treesitter' },
            { 'JoosepAlviste/nvim-ts-context-commentstring', after = 'nvim-treesitter' },
        })

        -- Navigation and Fuzzy Search --
        use {
            'nvim-tree/nvim-tree.lua',
            event = 'CursorHold',
            config = function()
                require('jimi.nvim-tree')
            end,
            requires = {
              'nvim-tree/nvim-web-devicons', -- optional
            },
          }
--        use({
--            'nvim-tree/nvim-tree.lua',
--            event = 'CursorHold',
--            config = function()
--                require('jimi.nvim-tree')
--            end,
--        })

        use({
            {
                'nvim-telescope/telescope.nvim',
                event = 'CursorHold',
                config = function()
                    require('jimi.telescope')
                end,
            },
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                after = 'telescope.nvim',
                run = 'make',
                config = function()
                    require('telescope').load_extension('fzf')
                end,
            },
        })

        -- Git
        use({
            'lewis6991/gitsigns.nvim',
            event = 'BufRead',
            config = function()
                require('jimi.gitsigns')
            end,
        })


        if PACKER_BOOTSTRAP then
            require("packer").sync()
        end
    end,
    config = {
        display = {
            open_fn = function()
                return require('packer.util').float({ border = 'single' })
            end,
        },
    },
})
