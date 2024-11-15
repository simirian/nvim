-- simirian's NeoVim
-- c language settings

--- @type Manager.Workspaces.Spec
return {
  detector = function()
    return vim.fs.root(vim.fn.getcwd(), { "CMakeLists.txt", "makefile" }) ~= nil
  end,
  filetypes = { "c", "cpp", "bash", "make", "cmake" },

  lsp = {
    clangd = {
      filetypes = { "c", "cpp" },
      cmd = { "clangd" },
    },
  },
}
