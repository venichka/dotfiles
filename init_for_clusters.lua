-- Minimal, cluster-friendly Neovim config (one file)
-- Save as: ~/.config/nvim/init.lua

local opt = vim.opt
local fn  = vim.fn

-- ===== Paths / storage (keep $HOME small) =====
local PHI_DATA = os.getenv("PHI_DATA") or "/data/phi/nikita"
local use_phi  = (fn.isdirectory(PHI_DATA) == 1)

local cache = fn.stdpath("cache")
local state = fn.stdpath("state")

local function ensure_dir(p)
  if fn.isdirectory(p) == 0 then fn.mkdir(p, "p") end
end

local base = use_phi and (PHI_DATA .. "/nvim") or (cache .. "/nvim")
local dir_swap   = base .. "/swap//"
local dir_backup = base .. "/backup//"
local dir_undo   = use_phi and (base .. "/undo//") or (state .. "/undo//")

ensure_dir(base)
ensure_dir(dir_swap:gsub("//$", ""))
ensure_dir(dir_backup:gsub("//$", ""))
ensure_dir(dir_undo:gsub("//$", ""))

opt.directory = dir_swap
opt.backupdir = dir_backup
opt.undodir   = dir_undo
opt.undofile  = true

-- ===== Sensible defaults =====
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true

opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.smartindent = true

opt.wrap = false
opt.linebreak = true
opt.breakindent = true

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

opt.splitright = true
opt.splitbelow = true

opt.completeopt = { "menuone", "noselect" }
opt.termguicolors = true
opt.updatetime = 300
opt.timeoutlen = 400

-- Clipboard: harmless if no provider exists on headless nodes
opt.clipboard:append("unnamedplus")

-- ===== Keymaps =====
vim.g.mapleader = " "
local map = vim.keymap.set

-- No save/quit maps (per your request)

-- Splits
map("n", "<leader>ws", "<cmd>split<cr>",  { desc = "Split horizontally" })
map("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Split vertically" })

-- Window navigation: <leader>w + hjkl
map("n", "<leader>wh", "<cmd>wincmd h<cr>", { desc = "Window left" })
map("n", "<leader>wj", "<cmd>wincmd j<cr>", { desc = "Window down" })
map("n", "<leader>wk", "<cmd>wincmd k<cr>", { desc = "Window up" })
map("n", "<leader>wl", "<cmd>wincmd l<cr>", { desc = "Window right" })

-- Buffers
map("n", "<leader>[", "<cmd>bp<cr>", { desc = "Prev buffer" })
map("n", "<leader>]", "<cmd>bn<cr>", { desc = "Next buffer" })

-- Tabs (minimal + mnemonic)
map("n", "<leader>tn", "<cmd>tabnew<cr>",     { desc = "New tab" })
map("n", "<leader>to", "<cmd>tabclose<cr>",   { desc = "Close tab" })
map("n", "<leader>t[", "<cmd>tabprevious<cr>",{ desc = "Prev tab" })
map("n", "<leader>t]", "<cmd>tabnext<cr>",    { desc = "Next tab" })

-- Small toggles for text editing
map("n", "<leader>tw", function() vim.wo.wrap = not vim.wo.wrap end,  { desc = "Toggle wrap" })
map("n", "<leader>ts", function() vim.wo.spell = not vim.wo.spell end,{ desc = "Toggle spell" })
map("n", "<leader>h",  "<cmd>nohlsearch<cr>", { desc = "No highlight" })

-- ===== Quick cheat sheet (no plugins) =====
local function open_cheatsheet()
  local lines = {
    "Neovim (cluster) quick keys",
    "",
    "Splits:",
    "  <leader>ws   split horizontally",
    "  <leader>wv   split vertically",
    "",
    "Window move:",
    "  <leader>wh   left",
    "  <leader>wj   down",
    "  <leader>wk   up",
    "  <leader>wl   right",
    "",
    "Buffers:",
    "  <leader>[    previous buffer",
    "  <leader>]    next buffer",
    "",
    "Tabs:",
    "  <leader>tn   new tab",
    "  <leader>to   close tab",
    "  <leader>t[   previous tab",
    "  <leader>t]   next tab",
    "",
    "Toggles:",
    "  <leader>tw   wrap",
    "  <leader>ts   spell",
    "  <leader>h    clear search highlight",
    "",
    "Close this window: press q",
  }

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "text"
  vim.bo[buf].modifiable = false

  local width  = math.floor(vim.o.columns * 0.55)
  local height = math.floor(vim.o.lines   * 0.60)
  local row    = math.floor((vim.o.lines - height) / 2)
  local col    = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  -- close with q
  map("n", "q", function()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end, { buffer = buf, nowait = true, silent = true })
end

map("n", "<leader>?", open_cheatsheet, { desc = "Cheat sheet" })

-- ===== QoL autocmds =====
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.highlight.on_yank({ timeout = 200 }) end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    vim.wo.wrap = true
    vim.wo.spell = true
  end,
})
