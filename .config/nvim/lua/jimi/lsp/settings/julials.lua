local julia = vim.fn.exepath("julia") or "julia"
local handlers = require("jimi.lsp.handlers")         -- ADD

-- Compute the workspace/env dir once (prefer Project.toml, else git root, else cwd)
local function julia_root()
  local markers = { "Project.toml", "JuliaProject.toml", ".git" }
  local found = vim.fs.find(markers, { upward = true, stop = vim.uv.os_homedir(), path = vim.api.nvim_buf_get_name(0) })
  if #found > 0 then
    local m = found[1]
    -- If we matched a file (Project.toml), take its dir; if ".git" dir, take its parent
    if m:match("Project%.toml$") or m:match("JuliaProject%.toml$") then
      return vim.fs.dirname(m)
    elseif m:match("%.git$") then
      return vim.fs.dirname(m)  -- project root
    end
  end
  return vim.loop.cwd()
end

local root = julia_root()


return {
  on_attach = handlers.on_attach,                      -- ADD
  capabilities = handlers.capabilities,                -- ADD
  -- root_dir = function(fname)
  --   -- use your smarter logic:
  --   return julia_root()
  --   -- (or use util.root_pattern(...) if you prefer)
  --   -- return util.root_pattern("Project.toml", "JuliaProject.toml", "Manifest.toml", ".git")(fname)
  -- end,
  settings = {
    julia = {
        NumThreads = 6,
        enableTelemetry = false,
    },
  },
  cmd = {
    julia, "--startup-file=no", "--history-file=no",
    "--project=@nvim-lspconfig",
    "-e", [[
      using Pkg
      Pkg.instantiate()
      using LanguageServer
      # Pass env path positionally (ARGS[1]); no keywords needed
      LanguageServer.runserver(stdin, stdout, isempty(ARGS) ? "" : ARGS[1])
    ]],
    root,  -- <-- ARGS[1] for the -e script above
  },
  filetypes = { "julia" },
  root_markers = { "Project.toml", "Manifest.toml", ".git" },
}


-- local opts = {
--     settings = {
--         julia = {
--             NumThreads = 6,
--             enableTelemetry = false,
--         },
--     },
--     setup = {
--         on_new_config = function(new_config, _)
--             local julia_bin = vim.fn.exepath("julia") or "/opt/homebrew/bin/julia"
--             if require'lspconfig'.util.path.is_file(julia_bin) then
--                 new_config.cmd[1] = julia_bin
--             end
--         end
--     },
-- }
--
-- return opts

