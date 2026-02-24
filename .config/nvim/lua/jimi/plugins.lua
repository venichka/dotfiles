local uv = vim.uv or vim.loop

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  { "nvim-lua/plenary.nvim" },
  { "nvim-tree/nvim-web-devicons" },

  {
    "RRethy/nvim-base16",
    lazy = false,
    priority = 1000,
    config = function()
      require("jimi.colorscheme")
    end,
  },

  {
    "lervag/vimtex",
    ft = { "tex", "plaintex", "bib" },
    init = function()
      vim.g.tex_flavor = "latex"
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_compiler_method = "latexmk"
      vim.o.conceallevel = 1
      vim.g.tex_conceal = ""
    end,
  },

  {
    "vimwiki/vimwiki",
    cmd = { "VimwikiIndex", "VimwikiDiaryIndex", "VimwikiTabIndex" },
    init = function()
      vim.g.vimwiki_global_ext = 0
      vim.g.vimwiki_list = {
        {
          auto_export = 1,
          auto_header = 1,
          automatic_nested_syntaxes = 1,
          path = "~/Google Drive/Work/Notes/vimwiki",
          path_html = "~/Google Drive/Work/Notes/vimwiki_html",
          template_path = "~/.dotfiles/vimwiki_conf/templates_html",
          template_default = "GitHub",
          template_ext = ".html5",
          syntax = "markdown",
          ext = ".md",
          custom_wiki2html = "~/Google Drive/Work/Notes/vimwiki/wiki2html_zsh.sh",
          autotags = 1,
          list_margin = 0,
          links_space_char = "_",
        },
      }
      vim.g.vimwiki_folding = ""
      vim.g.vimwiki_hl_headers = 1
      vim.g.vimwiki_ext2syntax = { [".md"] = "markdown" }
    end,
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
      { "<c-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
    },
    config = function()
      require("jimi.toggleterm")
    end,
  },

  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("colorizer").setup()
    end,
  },

  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "◍",
          package_pending = "◍",
          package_uninstalled = "◍",
        },
      },
      log_level = vim.log.levels.INFO,
      max_concurrent_installers = 4,
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = { "julials", "clangd", "texlab", "pylsp" },
      automatic_installation = false,
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "mason-org/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("jimi.lsp")
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lua",
      {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
      },
    },
    config = function()
      require("jimi.cmp")
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "hrsh7th/nvim-cmp", "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("jimi.autopairs")
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("jimi.lualine")
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
    end,
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
    opts = {
      preset = "modern",
      delay = 200,
      notify = false,
      spec = {
        { "<leader>f", group = "Find" },
        { "<leader>w", group = "Window" },
        { "<leader>l", group = "LSP" },
        { "<leader>h", group = "Config" },
        { "<leader>r", group = "REPL" },
        { "<leader>s", group = "Send" },
        { "<leader>m", group = "Mark" },
        { "<leader>?", desc = "Buffer local keymaps" },
        { "<leader>e", desc = "Explorer toggle" },
        { "<leader>[", desc = "Previous buffer" },
        { "<leader>]", desc = "Next buffer" },
        { "<leader>la", desc = "Code actions" },
        { "<leader>lf", desc = "Format buffer" },
        { "<leader>li", desc = "LSP info" },
        { "<leader>lI", desc = "Mason" },
        { "<leader>lj", desc = "Next diagnostic" },
        { "<leader>lk", desc = "Previous diagnostic" },
        { "<leader>lq", desc = "Diagnostics to loclist" },
        { "<leader>lr", desc = "Rename symbol" },
        { "<leader>ls", desc = "Signature help" },
        { "<leader>rr", desc = "REPL toggle" },
        { "<leader>rR", desc = "REPL restart" },
        { "<leader>rf", desc = "REPL focus" },
        { "<leader>rh", desc = "REPL hide" },
        { "<leader>sc", desc = "Send motion/selection" },
        { "<leader>sf", desc = "Send file" },
        { "<leader>sl", desc = "Send line" },
        { "<leader>sp", desc = "Send paragraph" },
        { "<leader>su", desc = "Send until cursor" },
        { "<leader>sm", desc = "Send mark" },
        { "<leader>sb", desc = "Send code block" },
        { "<leader>sn", desc = "Send code block and move" },
        { "<leader>s<cr>", desc = "Send carriage return" },
        { "<leader>s<space>", desc = "Send interrupt" },
        { "<leader>sq", desc = "Send exit" },
        { "<leader>cl", desc = "Clear REPL" },
        { "<leader>mc", desc = "Mark motion/selection" },
        { "<leader>md", desc = "Remove mark" },
        { "<leader>hh", desc = "Reload config" },
        { "<leader>o", desc = "New line below" },
        { "<leader>O", desc = "New line above" },
        { "<leader>wh", desc = "Focus left window" },
        { "<leader>wj", desc = "Focus lower window" },
        { "<leader>wk", desc = "Focus upper window" },
        { "<leader>wl", desc = "Focus right window" },
        { "<leader>wv", desc = "Vertical split" },
        { "<leader>ws", desc = "Horizontal split" },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-refactor",
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    opts = function()
      require("nvim-treesitter.install").prefer_git = true
      return {
        ensure_installed = { "julia" },
        ignore_install = { "ipkg" },
        auto_install = false,
        highlight = { enable = true },
        indent = { enable = true },
        refactor = {
          highlight_definitions = { enable = true },
          smart_rename = { enable = true },
          navigation = { enable = true },
        },
        context_commentstring = { enable = true, enable_autocmd = false },
      }
    end,
  },

  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    opts = function()
      local ok, integr = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
      return {
        pre_hook = ok and integr.create_pre_hook and integr.create_pre_hook() or nil,
      }
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorer toggle" },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("jimi.nvim-tree")
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<leader>fp", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      {
        "<leader>ff",
        function()
          local themes = require("telescope.themes")
          require("telescope.builtin").find_files(themes.get_dropdown({ previewer = false }))
        end,
        desc = "Find files (dropdown)",
      },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
      {
        "<leader>fu",
        function()
          local builtin = require("telescope.builtin")
          local utils = require("telescope.utils")
          local dir = utils.buffer_dir()
          if dir == "" then
            dir = uv.cwd()
          end
          builtin.find_files({ cwd = vim.fs.dirname(dir) or dir })
        end,
        desc = "Find files from parent dir",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    config = function()
      require("jimi.telescope")
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("jimi.gitsigns")
    end,
  },

  {
    "Vigemus/iron.nvim",
    cmd = {
      "IronRepl",
      "IronFocus",
      "IronHide",
      "IronRestart",
      "IronAttach",
      "IronSend",
    },
    keys = {
      { "<space>rr", "<cmd>IronRepl<cr>", mode = "n", desc = "Iron toggle REPL" },
      { "<space>rf", "<cmd>IronFocus<cr>", mode = "n", desc = "Iron focus REPL" },
      { "<space>rh", "<cmd>IronHide<cr>", mode = "n", desc = "Iron hide REPL" },
    },
    config = function()
      require("jimi.iron")
    end,
  },

  {
    "lewis6991/satellite.nvim",
    event = "VeryLazy",
    config = function()
      require("jimi.satellite")
    end,
  },
}

require("lazy").setup(plugins, {
  defaults = { lazy = true, version = false },
  install = { colorscheme = { "base16-onedark" } },
  checker = { enabled = true, notify = false },
  change_detection = { enabled = true, notify = false },
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "netrwPlugin", "tohtml", "tarPlugin", "rrhelper" },
    },
  },
})
