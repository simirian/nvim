-- lua language server configuration

--- @type Lsp.Config
return {
  get_root = { ".luarc.json", ".stylua.toml", ".luacheckrc" },
  filetypes = "lua",
  config = function()
    local config = {
      cmd = { "lua-language-server" },
    }
    --- @diagnostic disable-next-line: undefined-field
    if vim.loop.cwd():match("[/\\]nvim$") then
      config.settings = { Lua = { workspace = { library = vim.api.nvim_list_runtime_paths() } } }
    end
    return config
  end,
}
