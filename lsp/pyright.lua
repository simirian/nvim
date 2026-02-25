--- @type vim.lsp.Config
return {
  -- used nvim-lspconfig to figure out the correct command to use
  cmd = { "pyright-langserver", "--stdio" },
  -- root_markers = { "pyproject.toml", ".venv", "pyrightconfig.json", ".git" },
  filetypes = { "python" },
  settings = {
    analysis = {
      autoSearchPaths = true,
      useLibraryCodeForTypes = true,
    },
  },
}
