local handlers = require("jimi.lsp.handlers")

local servers = {
  "julials",
  "clangd",
  "texlab",
  "pylsp",
}

vim.lsp.config("clangd", {
  on_attach = handlers.on_attach,
  capabilities = handlers.capabilities,
})

local pylsp_opts = require("jimi.lsp.settings.pylsp")
vim.lsp.config("pylsp", vim.tbl_deep_extend("force", pylsp_opts, {
  on_attach = handlers.on_attach,
  capabilities = handlers.capabilities,
}))

vim.lsp.config("texlab", {
  on_attach = handlers.on_attach,
  capabilities = handlers.capabilities,
})

local julials_opts = require("jimi.lsp.settings.julials")
vim.lsp.config("julials", vim.tbl_deep_extend("force", julials_opts, {
  on_attach = handlers.on_attach,
  capabilities = handlers.capabilities,
}))

for _, server in ipairs(servers) do
  vim.lsp.enable(server)
end
