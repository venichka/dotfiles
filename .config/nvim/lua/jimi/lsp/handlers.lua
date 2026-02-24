local M = {}

-- cmp_nvim_lsp is optional; continue even if it's not installed so this module can be required safely.
local status_cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")

M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities.textDocument.completion.completionItem.snippetSupport = true
if status_cmp_ok and cmp_nvim_lsp then
  M.capabilities = cmp_nvim_lsp.default_capabilities(M.capabilities)
end

M.setup = function()
  local icons = {
    Error = "",
    Warn  = "",
    Hint  = "󰌵",
    Info  = "",
  }

  -- Optional: ensure highlight groups exist / link to default Diagnostic groups
  -- (Neovim already defines these, but you can override if you like)
  -- vim.api.nvim_set_hl(0, "DiagnosticSignError", { link = "DiagnosticError" })
  -- vim.api.nvim_set_hl(0, "DiagnosticSignWarn",  { link = "DiagnosticWarn"  })
  -- vim.api.nvim_set_hl(0, "DiagnosticSignHint",  { link = "DiagnosticHint"  })
  -- vim.api.nvim_set_hl(0, "DiagnosticSignInfo",  { link = "DiagnosticInfo"  })

  -- NEW: configure sign text/numhl via vim.diagnostic.config (no sign_define)
  vim.diagnostic.config({
    virtual_text = false,      -- like your previous config
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    signs = {
      -- You can provide text per severity. This replaces sign_define loops.
      text = {
        [vim.diagnostic.severity.ERROR] = icons.Error,
        [vim.diagnostic.severity.WARN]  = icons.Warn,
        [vim.diagnostic.severity.HINT]  = icons.Hint,
        [vim.diagnostic.severity.INFO]  = icons.Info,
      },
      -- If you want number column highlights, map severities to groups:
      numhl = {
        [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
        [vim.diagnostic.severity.WARN]  = "DiagnosticSignWarn",
        [vim.diagnostic.severity.HINT]  = "DiagnosticSignHint",
        [vim.diagnostic.severity.INFO]  = "DiagnosticSignInfo",
      },
    },
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  })

  -- Border configs unchanged:
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, { border = "rounded" }
  )
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help, { border = "rounded" }
  )
end




local function lsp_keymaps(bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  local keymap = vim.keymap.set
  local function nmap(lhs, rhs, desc)
    keymap("n", lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
  end

  nmap("gD", vim.lsp.buf.declaration, "LSP declaration")
  nmap("gd", vim.lsp.buf.definition, "LSP definition")
  nmap("K", vim.lsp.buf.hover, "LSP hover")
  nmap("gI", vim.lsp.buf.implementation, "LSP implementation")
  nmap("gr", vim.lsp.buf.references, "LSP references")
  nmap("gl", vim.diagnostic.open_float, "Line diagnostics")
  nmap("<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format buffer")
  nmap("<leader>li", "<cmd>LspInfo<cr>", "LSP info")
  nmap("<leader>lI", "<cmd>Mason<cr>", "Mason")
  nmap("<leader>la", vim.lsp.buf.code_action, "Code actions")
  nmap("<leader>lj", vim.diagnostic.goto_next, "Next diagnostic")
  nmap("<leader>lk", vim.diagnostic.goto_prev, "Previous diagnostic")
  nmap("<leader>lr", vim.lsp.buf.rename, "Rename symbol")
  nmap("<leader>ls", vim.lsp.buf.signature_help, "Signature help")
  nmap("<leader>lq", vim.diagnostic.setloclist, "Diagnostics to loclist")
end

M.on_attach = function(client, bufnr)
   if client.name == "tsserver" then
     client.server_capabilities.documentFormattingProvider = false
   end

  -- handle both legacy and new lua LSP names
  if client.name == "sumneko_lua" or client.name == "lua_ls" then
    client.server_capabilities.documentFormattingProvider = false
  end

  lsp_keymaps(bufnr)
   local status_ok, illuminate = pcall(require, "illuminate")
   if not status_ok then
     return
   end
   illuminate.on_attach(client)
 end

return M
