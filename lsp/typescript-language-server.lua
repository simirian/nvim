--- @type vim.lsp.Config
return {
  cmd = { "typescript-language-server", "--stdio" },
  root_markers = { "project.json", "tsconfig.json", "jsconfig.json", ".git" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
}
