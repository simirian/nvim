--- @type vim.lsp.Config
return {
  cmd = { "lua-language-server" },
  root_markers = { ".luarc.json", ".stylua.toml", ".luacheckrc", ".git" },
  filetypes = { "lua" },
}
