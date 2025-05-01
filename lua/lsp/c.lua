-- clangd configuration

--- @type Lsp.Config
return {
  get_root = { ".clangd", ".clang-tidy", ".clang-format" },
  filetypes = { "c", "cpp" },
  config = {
    cmd = { "clangd" },
  },
}
