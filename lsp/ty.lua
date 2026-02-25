--- @type vim.lsp.Config
return {
  cmd = { "ty", "server" },
  root_markers = { "pyproject.toml", ".venv", "ty.toml", ".git" },
  filetypes = { "python" },
}
