-- clangd configuration

--- @type Lsp.Config
return {
  get_root = { "Cargo.toml", "Cargo.lock" },
  filetypes = "rust",
  config = {
    cmd = { "rust-analyzer" },
  },
}
