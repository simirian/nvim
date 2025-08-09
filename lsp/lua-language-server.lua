--- @type vim.lsp.Config
return {
  cmd = { "lua-language-server" },
  root_markars = { ".luarc.json", ".stylua.toml", ".luacheckrc" },
  filetypes = { "lua" },
}
