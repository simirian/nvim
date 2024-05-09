-- simirian's NeoVim
-- c language settings

return {
  detector = function()
    -- look for a `makefile` or `CMakeLists.txt`
    local cwd = vim.fn.getcwd()
    return DirContains(cwd, "makefile")
        or DirContains(cwd, "CMakeLists.txt")
  end,
  workspace_root = { "CMakeLists.txt", "makefile" },
  filetypes = "cpp",

  lsp = {
    ["clangd"] = {}
  },
}
