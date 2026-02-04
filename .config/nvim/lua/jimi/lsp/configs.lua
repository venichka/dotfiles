local status_ok, mason = pcall(require, "mason")
if not status_ok then
  return
end

local status_ok_1, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status_ok_1 then
  return
end

local servers = {
    --"sumneko_lua",
    "julials",
    "clangd",
    "texlab",
    "pylsp",
}

-- mason settings
local settings = {
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
}

mason.setup(settings)
mason_lspconfig.setup({
  ensure_installed = servers,
  automatic_installation = true,
})


-- local opts = {}
--
-- for _, server in pairs(servers) do
--   opts = {
--     on_attach = require("jimi.lsp.handlers").on_attach,
--     capabilities = require("jimi.lsp.handlers").capabilities,
--   }
--
--   if server == "sumneko_lua" then
--     local sumneko_opts = require "jimi.lsp.settings.sumneko_lua"
--     opts = vim.tbl_deep_extend("force", sumneko_opts, opts)
--   end
--
--   if server == "pylsp" then
--     local pylsp_opts = require "jimi.lsp.settings.pylsp"
--     opts = vim.tbl_deep_extend("force", pylsp_opts, opts)
--   end
--
--   -- if server == "julials" then
--   --    local julials_opts = require "jimi.lsp.settings.julials"
--   --    opts = vim.tbl_deep_extend("force", julials_opts, opts)
--   -- end
--
--   -- lspconfig[server].setup(opts)  --  depricated
--   -- vim.lsp.config(server, opts)
--   vim.lsp.enable(server)
-- end

local handlers = require("jimi.lsp.handlers")

-- Define/extend server configs once
vim.lsp.config('clangd', {
  on_attach = handlers.on_attach,
  capabilities = handlers.capabilities,
})

vim.lsp.config('pylsp', {
  on_attach = handlers.on_attach,
  capabilities = handlers.capabilities,
})

vim.lsp.config('texlab', {
  on_attach = handlers.on_attach,
  capabilities = handlers.capabilities,
})

local julials_opts = require "jimi.lsp.settings.julials"
vim.lsp.config('julials', vim.tbl_deep_extend("force", julials_opts ,{
  on_attach = handlers.on_attach,
  capabilities = handlers.capabilities,
}))

-- vim.lsp.config('julials', dofile(vim.fn.stdpath('config') .. '/lua/jimi/lsp/julials_config.lua'))


-- Attach when buffers with these filetypes open
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "objc", "objcpp", "cuda" },
  callback = function() vim.lsp.enable('clangd') end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function() vim.lsp.enable('pylsp') end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "plaintex", "bib" },
  callback = function() vim.lsp.enable('texlab') end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "julia" },
  callback = function() vim.lsp.enable('julials') end,
})

--vim.api.nvim_create_autocmd("FileType", {
--  pattern = { "julia" },
--  callback = function() vim.lsp.enable('julials') end,  -- <— use the registered config
--})
