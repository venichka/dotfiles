local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
		return
end

toggleterm.setup({
	size = 10,
	open_mapping = [[<c-\>]],
	hide_numbers = true,
	shade_terminals = true,
	shading_factor = 2,
	start_in_insert = true,
	insert_mappings = true,
	persist_size = true,
	direction = "horizontal",
	close_on_exit = true,
	shell = vim.o.shell,
	float_opts = {
		border = "curved",
	},
})

local function set_terminal_keymaps(bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }
  vim.keymap.set("t", "<leader>wh", [[<C-\><C-n><C-W>h]], vim.tbl_extend("force", opts, { desc = "Terminal: focus left window" }))
  vim.keymap.set("t", "<leader>wj", [[<C-\><C-n><C-W>j]], vim.tbl_extend("force", opts, { desc = "Terminal: focus lower window" }))
  vim.keymap.set("t", "<leader>wk", [[<C-\><C-n><C-W>k]], vim.tbl_extend("force", opts, { desc = "Terminal: focus upper window" }))
  vim.keymap.set("t", "<leader>wl", [[<C-\><C-n><C-W>l]], vim.tbl_extend("force", opts, { desc = "Terminal: focus right window" }))
end

local term_group = vim.api.nvim_create_augroup("JimiToggleTerm", { clear = true })
vim.api.nvim_create_autocmd("TermOpen", {
  group = term_group,
  pattern = "term://*",
  callback = function(args)
    set_terminal_keymaps(args.buf)
  end,
})
