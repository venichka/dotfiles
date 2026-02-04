local status_ok, comment = pcall(require, "Comment")
if not status_ok then
  return
end

-- Ensure ts_context_commentstring is initialized (safe call)
pcall(function()
  require("ts_context_commentstring").setup({})
end)

comment.setup {
  -- use the official integration pre-hook (handles visual/line/block correctly)
  pre_hook = (function()
    local ok, integr = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
    if ok and integr and integr.create_pre_hook then
      return integr.create_pre_hook()
    end
    -- fallback: nil (no pre_hook) if the integration is missing
    return nil
  end)(),
}
