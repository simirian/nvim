--- @type vim.lsp.Config
return {
  cmd = { "rust-analyzer" },
  root_markers = { "Cargo.toml", "Cargo.lock" },
  filetypes = { "rust" },
}
