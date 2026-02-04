local vimtex_status_ok, vimtex = pcall(require, "vimtex")
if not vimtex_status_ok then
  return
end

vim.g.tex_flavor = 'latex'
vim.g.vimtex_view_method = 'skim'
vim.g.vimtex_quickfix_mode = 0   -- fixed typo
vim.o.conceallevel = 1
vim.g.tex_conceal = 'abdmg'
