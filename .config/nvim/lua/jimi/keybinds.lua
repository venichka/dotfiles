local function map(modes, lhs, rhs, desc, extra)
  local opts = vim.tbl_extend("force", { silent = true, desc = desc }, extra or {})
  vim.keymap.set(modes, lhs, rhs, opts)
end

-- Disable bare space key
map("", "<Space>", "<Nop>", "Disable Space")

-- Normal mode: window navigation
map("n", "<leader>wh", "<C-w>h", "Focus left window")
map("n", "<leader>wj", "<C-w>j", "Focus lower window")
map("n", "<leader>wk", "<C-w>k", "Focus upper window")
map("n", "<leader>wl", "<C-w>l", "Focus right window")

-- Normal mode: split window
map("n", "<leader>wv", ":vsplit<CR>", "Vertical split")
map("n", "<leader>ws", ":split<CR>", "Horizontal split")

-- Normal mode: resize splits
map("n", "<A-Up>", ":resize +2<CR>", "Increase split height")
map("n", "<A-Down>", ":resize -2<CR>", "Decrease split height")
map("n", "<A-Left>", ":vertical resize -2<CR>", "Decrease split width")
map("n", "<A-Right>", ":vertical resize +2<CR>", "Increase split width")

-- Normal mode: config reload
map("n", "<leader>hh", ":source $MYVIMRC<CR>", "Reload config")

-- Normal mode: search behavior tweaks
map("n", "*", "*N", "Search word without moving to next")
map("n", "n", "nzz", "Next search result centered")
map("n", "N", "Nzz", "Previous search result centered")

-- Normal mode: quit
map("n", "<C-Q>", "<CMD>q<CR>", "Quit window")

-- Normal mode: insert blank lines
map("n", "<leader>o", "o<ESC>", "New line below")
map("n", "<leader>O", "O<ESC>", "New line above")

-- Normal mode: buffer navigation
map("n", "<leader>[", "<CMD>bp<CR>", "Previous buffer")
map("n", "<leader>]", "<CMD>bn<CR>", "Next buffer")
map("n", "''", "<CMD>b#<CR>", "Last buffer")

-- Normal mode: split shortcut
map("n", "<A-\\>", "<CMD>split<CR>", "Horizontal split (alt)")

-- Normal and visual mode: move lines
map("n", "<C-j>", "<CMD>move .+1<CR>", "Move line down")
map("n", "<C-k>", "<CMD>move .-2<CR>", "Move line up")
map("x", "<C-j>", ":move '>+1<CR>gv=gv", "Move selection down")
map("x", "<C-k>", ":move '<-2<CR>gv=gv", "Move selection up")

-- Operator-pending and visual: whole-buffer text object
map("o", "A", ":<C-U>normal! mzggVG<CR>`z", "Select all (operator-pending)")
map("x", "A", ":<C-U>normal! ggVG<CR>", "Select all")

-- Insert mode: shell-style cursor movement
map("i", "<C-E>", "<ESC>A", "Move to line end")
map("i", "<C-A>", "<ESC>I", "Move to line start")
map("i", "jk", "<ESC>", "Exit insert mode")

-- Visual mode: indentation and paste behavior
map("v", "<", "<gv", "Indent left and reselect")
map("v", ">", ">gv", "Indent right and reselect")
map("v", "<A-j>", ":m .+1<CR>==", "Move selection down")
map("v", "<A-k>", ":m .-2<CR>==", "Move selection up")
map("v", "p", '"_dP', "Paste without overwriting default register")
