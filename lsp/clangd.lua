--- @type vim.lsp.Config
return {
  cmd = { "clangd" },
  root_markers = { ".clangd", "compile_commands.json", ".clang-tidy", ".clang-format", ".git" },
  filetypes = { "c", "cpp" },
}
