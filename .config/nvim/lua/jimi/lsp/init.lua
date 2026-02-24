-- 1) Base handlers (diagnostics, keymaps, etc.)
require("jimi.lsp.handlers").setup()

-- 2) Define non-Julia LSPs via Nvim 0.11 API and their FileType autocmds
require("jimi.lsp.configs")


-- === :JuliaProjectRoot command =============================================
-- Prints the project root we detect for the current buffer, and any
-- workspace folders from attached julials clients.

local function _julia_project_root_for_buf(bufnr)
  bufnr = bufnr or 0
  local start = vim.api.nvim_buf_get_name(bufnr)
  if start == "" then start = vim.uv.cwd() end
  local markers = { "Project.toml", "JuliaProject.toml", ".git" }
  local found = vim.fs.find(markers, { upward = true, path = start, stop = vim.uv.os_homedir() })
  if #found == 0 then return vim.uv.cwd() end
  local m = found[1]
  if m:match("Project%.toml$") or m:match("JuliaProject%.toml$") then
    return vim.fs.dirname(m)
  else
    return vim.fs.dirname(m) -- matched ".git"
  end
end

vim.api.nvim_create_user_command("JuliaProjectRoot", function()
  local detected = _julia_project_root_for_buf(0)

  -- Gather workspace folders from any julials clients attached to this buffer
  local lines = {}
  table.insert(lines, "Detected project root: " .. detected)

  local clients = vim.lsp.get_clients({ name = "julials", bufnr = 0 })
  if #clients == 0 then
    table.insert(lines, "No julials clients attached to this buffer.")
  else
    for _, c in ipairs(clients) do
      table.insert(lines, ("Client %d (id=%s) workspace folders:"):format(c.id or 0, c.id or "?"))
      if c.workspace_folders and #c.workspace_folders > 0 then
        for _, wf in ipairs(c.workspace_folders) do
          local uri = wf.uri or wf.name
          local path = uri and vim.uri_to_fname(uri) or "(unknown)"
          table.insert(lines, "  - " .. path)
        end
      else
        -- Fallbacks if workspace_folders isn’t populated
        local root = (c.root_dir or (c.config and c.config.root_dir)) or "(none)"
        table.insert(lines, "  - (no workspace_folders; root_dir = " .. root .. ")")
      end
    end
  end

  -- Show a pretty, scrollable message window
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Julia Project Root" })
end, { desc = "Show detected Julia project root and julials workspace folders" })
-- ===========================================================================
