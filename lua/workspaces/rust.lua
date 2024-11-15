-- simirian's NeoVim
-- rust language settings

--- @type Manager.Workspaces.Spec
return {
  detector = function()
    return vim.fs.root(vim.loop.cwd(), { "Cargo.toml", "Cargo.lock" }) ~= nil
  end,
  filetypes = { "rust" },

  lsp = {
    rust_analyzer = {
      filetypes = "rust",
      cmd = { "rust-analyzer" },
    },
  },
}
