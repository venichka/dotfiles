local julia = vim.fn.exepath("julia") or "julia"
local handlers = require("jimi.lsp.handlers")

local function julia_root(startpath)
  local markers = { "Project.toml", "JuliaProject.toml", ".git" }
  local search_from = startpath
  if not search_from or search_from == "" then
    search_from = vim.uv.cwd()
  end

  local found = vim.fs.find(markers, {
    upward = true,
    stop = vim.uv.os_homedir(),
    path = search_from,
  })

  if #found > 0 then
    local marker = found[1]
    if marker:match("Project%.toml$") or marker:match("JuliaProject%.toml$") then
      return vim.fs.dirname(marker)
    end
    if marker:match("%.git$") then
      return vim.fs.dirname(marker)
    end
  end

  return vim.uv.cwd()
end

local function julials_cmd(root_dir)
  local project_root = julia_root(root_dir)
  return {
    julia,
    "--startup-file=no",
    "--history-file=no",
    "--project=@nvim-lspconfig",
    "-e",
    [[
      using Pkg
      Pkg.instantiate()
      using LanguageServer
      LanguageServer.runserver(stdin, stdout, isempty(ARGS) ? "" : ARGS[1])
    ]],
    project_root,
  }
end

return {
  on_attach = handlers.on_attach,
  capabilities = handlers.capabilities,
  settings = {
    julia = {
      NumThreads = 6,
      enableTelemetry = false,
    },
  },
  cmd = julials_cmd(vim.uv.cwd()),
  on_new_config = function(new_config, new_root_dir)
    new_config.cmd = julials_cmd(new_root_dir)
  end,
  filetypes = { "julia" },
  root_markers = { "Project.toml", "Manifest.toml", ".git" },
}
