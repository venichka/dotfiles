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
  })  -- ← this is the supported way in 0.11+ for diagnostic signs. :contentReference[oaicite:3]{index=3}

  -- Border configs unchanged:
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, { border = "rounded" }
  )
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help, { border = "rounded" }
  )
end




local function lsp_keymaps(bufnr)
  local opts = { noremap = true, silent = true }
  local keymap = vim.api.nvim_buf_set_keymap
  keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  keymap(bufnr, "n", "gI", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  keymap(bufnr, "n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  -- prefer new API; use async format
  keymap(bufnr, "n", "<leader>lf", "<cmd>lua vim.lsp.buf.format({ async = true })<cr>", opts)
  keymap(bufnr, "n", "<leader>li", "<cmd>LspInfo<cr>", opts)
  keymap(bufnr, "n", "<leader>lI", "<cmd>LspInstallInfo<cr>", opts)
  keymap(bufnr, "n", "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
  keymap(bufnr, "n", "<leader>lj", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>", opts)
  keymap(bufnr, "n", "<leader>lk", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", opts)
  keymap(bufnr, "n", "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
  keymap(bufnr, "n", "<leader>ls", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  keymap(bufnr, "n", "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
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
