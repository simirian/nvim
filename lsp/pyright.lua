-- used nvim-lspconfig to figure this out

--- @type vim.lsp.Config
return {
  cmd = { "pyright-langserver", "--stdio" },
  root_markers = { "pyproject.toml", ".venv", "pyrightconfig.json" },
  filetypes = { "python" },
  settings = {
    analysis = {
      autoSearchPaths = true,
      useLibraryCodeForTypes = true,
    },
  },
}
