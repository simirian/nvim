--- @type vim.lsp.Config
return {
  cmd = { "ty", "server" },
  root_markers = { "pyproject.toml", ".venv", "ty.toml" },
  filetypes = { "python" },
}
