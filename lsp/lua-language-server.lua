--- @type vim.lsp.Config
return {
  cmd = { "lua-language-server" },
  root_markars = { ".luarc.json", ".stylua.toml", ".luacheckrc" },
  filetypes = { "lua" },
  on_init = function(client)
    -- If the root directory is an nvim project, then we update the settings to
    -- use RTP directories as library directories.
    if client.root_dir then
      local root = vim.fs.normalize(client.root_dir)
      if root:match("[^/]*$"):find("nvim", 1, true) then
        client.settings = { Lua = { workspace = { library = vim.api.nvim_list_runtime_paths() } } }
        client:notify("workspace/didChangeConfiguration", { settings = { Lsp = { workspace = { library = true } } } })
      end
    end
  end,
}
