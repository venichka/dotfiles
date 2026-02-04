local status_ok, vimwiki = pcall(require, "vimwiki")
if not status_ok then
  return
end


vim.cmd("filetype plugin on")
vim.g.vimwiki_global_ext = 0
vim.g.vimwiki_list = {{
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
    custom_wiki2html = "~/Google Drive/Work/Notes/vimwiki/wiki2html.sh",
    autotags = 1,
    list_margin = 0,
    links_space_char = "_",
    }}
vim.g.vimwiki_folding="expr"
vim.g.vimwiki_hl_headers = 1
vim.g.vimwiki_ext2syntax = {[".md"] = "markdown"}
