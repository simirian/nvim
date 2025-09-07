--- @type vim.lsp.Config
return {
  cmd = { "ruff", "server" },
  root_markers = { "pyproject.toml", ".venv", "pyrightconfig.json" },
  filetypes = { "python" },
}
