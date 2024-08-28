-- simirian's NeoVim
-- lua language settings

return {
  detector = function()
    local cwd = vim.fn.getcwd()
    if string.match(vim.fs.basename(cwd), "nvim") then return true end
    if vim.fs.basename(cwd) == "awesome" then return true end
    return vim.fs.root(cwd, ".luarc.json") ~= nil
  end,
  filetypes = { "lua", "vim", "vimdoc" },

  lsp = {
    ["lua-language-server"] = {
      filetypes = "lua",
      cmd = { "lua-language-server.cmd" },
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
          },
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            checkThirdParty = false,
            library = vim.api.nvim_list_runtime_paths(),
          },
        },
      },
    },
  },
}
