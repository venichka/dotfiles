-- ~/.config/nvim/lua/plugins.lua
local fn = vim.fn


-- Bootstrap lazy.nvim and setup plugin specs here (migrated from packer)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  defaults = { lazy = true, version = false },
  install = { colorscheme = { "base16-onedark" } },
  change_detection = { enabled = true },
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "netrwPlugin", "tohtml", "tarPlugin", "rrhelper" },
    },
  },

  -- Plugin specs (keep using your lua/jimi/* config modules)
  { "nvim-lua/plenary.nvim", lazy = false },


  {"lervag/vimtex"},  -- latex support
  {"vimwiki/vimwiki"},  -- vimwiki

  {
    "akinsho/toggleterm.nvim",
    event = "CursorHold",
    --config = function() require("jimi.toggleterm") end,
  },

  {
    "norcalli/nvim-colorizer.lua",
    event = "CursorHold",
    config = function() require("colorizer").setup() end,
  },

  {
    "neovim/nvim-lspconfig",
    event = "BufRead",
    -- lazy=false,
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    -- config = function() require("jimi.lsp") end,
  },

  { "williamboman/mason.nvim", lazy = false },
  { "williamboman/mason-lspconfig.nvim", lazy = false },

  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    -- config = function() require("jimi.cmp") end,
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lua",
      {
        "L3MON4D3/LuaSnip",
        event = "InsertEnter",
        dependencies = { "rafamadriz/friendly-snippets" },
      },
    },
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertCharPre",
    after = "nvim-cmp",
    config = function() require("jimi.autopairs") end,
  },

  { "nvim-tree/nvim-web-devicons", lazy = false },

  {
    "RRethy/nvim-base16",
    config = function() require("jimi.colorscheme") end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "BufEnter",
    after = "nvim-base16",
    config = function() require("jimi.lualine") end,
  },


  -- nvim-treesitter + friends (Lazy spec)
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    -- let treesitter be configured via opts:
    main = "nvim-treesitter.configs",
    -- use dependencies instead of `after`
    dependencies = {
      "nvim-treesitter/nvim-treesitter-refactor",
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    init = function()
      -- optional: use git instead of curl for fetching parsers (often more reliable)
      require("nvim-treesitter.install").prefer_git = true
      -- example: proxy/curl args if you ever need them:
      -- require("nvim-treesitter.install").command_extra_args = { curl = { "--proxy", "http://127.0.0.1:3128" } }
    end,
    opts = {
      -- install only what you need (add/remove languages you use)
      ensure_installed = {
        "julia",
      },
      -- important: skip the parser that’s throwing "Unrecognized archive format"
      ignore_install = { "ipkg" },
      auto_install = false,        -- don’t auto-install on buffer enter
      highlight = { enable = true },
      indent    = { enable = true },
      -- module settings for refactor, etc.
      refactor = {
        highlight_definitions = { enable = true },
        smart_rename = { enable = true },
        navigation = { enable = true },
      },
      -- context-commentstring can be enabled here if you don’t wire it via Comment.nvim
      context_commentstring = { enable = true, enable_autocmd = false },
    },
  },
  
  -- If you use Comment.nvim, wire the TS context-commentstring pre_hook:
  {
    "numToStr/Comment.nvim",
    event = "BufReadPost",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    opts = function()
      return {
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
    end,
  },

  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   event = "CursorHold",
  --   build = ":TSUpdate",
  --   config = function() require("jimi.treesitter") end,
  -- },

  -- { "nvim-treesitter/nvim-treesitter-refactor", after = "nvim-treesitter" },
  -- { "JoosepAlviste/nvim-ts-context-commentstring", after = "nvim-treesitter" },

  {
    "nvim-tree/nvim-tree.lua",
    event = "CursorHold",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- config = function() require("jimi.nvim-tree") end,
  },

  {
    "nvim-telescope/telescope.nvim",
    event = "BufReadPost",
    dependencies = { "nvim-lua/plenary.nvim" },
    -- config = function() require("jimi.telescope") end,
  },

  {
    "nvim-telescope/telescope-fzf-native.nvim",
    after = "telescope.nvim",
    build = "make",
    config = function()
      pcall(function() require("telescope").load_extension("fzf") end)
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = "BufRead",
    config = function() require("jimi.gitsigns") end,
  },

  {'Vigemus/iron.nvim'},

  {"lewis6991/satellite.nvim"},

  -- keep any additional specs or local plugins below
})
