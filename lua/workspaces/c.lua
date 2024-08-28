-- simirian's NeoVim
-- c language settings

return {
  detector = function()
    return vim.fs.root(vim.fn.getcwd(), { "CMakeLists.txt", "makefile" }) ~= nil
  end,
  filetypes = { "c", "bash", "make", "cmake" },

  lsp = {
    ["clangd"] = {
      filetypes = { "c", "cpp" },
      cmd = { "clangd.cmd" },
    },
  },
}
