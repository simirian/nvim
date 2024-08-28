-- simirian's NeoVim
-- rust language settings

local vfs = vim.fs

return {
  detector = function()
    return vfs.root(vim.fn.getcwd(), { "Cargo.toml", "Cargo.lock" }) ~= nil
  end,
  filetypes = { "rust" },

  lsp = {
    ["rust_analyzer"] = {
      filetypes = "rust",
      cmd = { "rust-analyzer.cmd" },
      settings = { ["rust-analyzer"] = { }, },
    },
  },
}
