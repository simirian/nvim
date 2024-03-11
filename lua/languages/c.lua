-- simirian's NeoVim
-- c language settings

local langs = require("languages")

return {
  detector = function()
    -- look for a `makefile` or `CMakeLists.txt`
    local cwd = vim.fn.getcwd()
    return langs.dir_contains(cwd, "makefile")
      or langs.dir_contains(cwd, "CMakeLists.txt")
  end,
  workspace_root = { "CMakeLists.txt", "makefile" },
  filetypes = "c",

  lsp = {
    name = "clangd",
    settings = { },
  },
}

