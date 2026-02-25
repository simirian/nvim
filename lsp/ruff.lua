--- @type vim.lsp.Config
return {
  cmd = { "ruff", "server" },
  root_markers = { "pyproject.toml", ".venv", "ruff.toml", ".git" },
  filetypes = { "python" },
}
