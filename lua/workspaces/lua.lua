-- simirian's NeoVim
-- lua language settings

return {
  detector = function()
    -- look for specific workspace names
    local cwd = vim.fn.getcwd()
    if string.match(vim.fs.basename(cwd), "nvim") then return true end
    if vim.fs.basename(cwd) == "awesome" then return true end

    -- look for a `.luarc.json` file
    return DirContains(cwd, ".luarc.json")
  end,
  filetypes = "lua",

  lsp = {
    ["lua_ls"] = {
      settings = {
        ["Lua"] = {
          runtime = {
            version = "LuaJIT",
          },
          diagnostics = {
            enable = true,
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
