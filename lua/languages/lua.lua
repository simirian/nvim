-- simirian's NeoVim
-- lua language settings

local langs = require("languages")

return {
  detector = function()
    -- look for specific workspace names
    local cwd = vim.fn.getcwd()
    if vim.fs.basename(cwd) == "nvim" then return true end
    if vim.fs.basename(cwd) == "awesome" then return true end

    -- look for a `.luarc.json` file
    return langs.dir_contains(cwd, ".luarc.json")
  end,
  -- use default `.git/` dir with `.luarc.json` as backup
  workspace_root = { "./git", ".luarc.json" },
  filetypes = "lua",
  ts_parser = "lua",

  lsp = {
    name = "lua_ls",
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
          library = {
            vim.env.VIMRUNTIME,
            "${3rd}/luassert/library",
          },
        },
      },
    },
  },
}

