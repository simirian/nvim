-- simirian's NeoVim
-- rust language settings

local langs = require("languages")

return {
  detector = function()
    -- look for a `Cargo.toml` file
    local cwd = vim.fn.getcwd()
    return langs.dir_contains(cwd, "Cargo.toml")
  end,
  workspace_root = "Cargo.toml",
  filetypes = "rust",

  lsp = {
    name = "rust_analyzer",
    settings = {
      ["rust-analyzer"] = {
        completion = {
          autoimport = { enable = true },
          autoself = { enable = true },
          callable = { snippets = "fill_arguments" },
          limit = nil,
          postfix = { enable = true },
          privateEditable = { enable = true },
        },
        diagnostics = {
          disabled = { },
          enable = true,
        },
      },
    },
  },
}

