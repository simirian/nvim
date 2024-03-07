-- simirian's NeoVim
-- basic settings used in many other places

return {
  colorscheme = "kanagawa",

  languages = {
    -- cpp
    clangd = { },

    -- lua
    lua_ls = {
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

    -- rust
    rust_analyzer = {
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

    -- web
    --html = { },
    --tsserver = { },
    --cssls = { },

    -- python
    --pylyzer = { },
  },

  icons = {
    -- item kind icons
    Array = "",
    Boolean = "",
    Class = "󱪵",
    Color = "",
    Constant = "󰭷",
    Constructor = "",
    Enum = "󱃣",
    EnumMember = "󰎢",
    Event = "",
    Field = "",
    File = "󰈤",
    Folder = "󰉋",
    Function = "󰊕",
    Interface = "",
    Key = "",
    Keyword = "",
    Method = "󰘧",
    Module = "",
    Namespace = "",
    Null = "󱥸",
    Number = "",
    Object = "󰔇",
    Operator = "󱓉",
    Package = "",
    Property = "",
    Reference = "",
    Snippet = "󰩫",
    String = "󰬴",
    Struct = "",
    Text = "󰈙",
    TypeParameter = "󰓹",
    Unit = "",
    Value = "󰺢",
    Variable = "󰄪",

    -- diagnostic icons
    Error = "",
    Warning = "",
    Information = "",
    Question = "",
    Hint = "󰌵",
    Debug = "",
    Trace = "",
    Ok = "",
    Pause = "",
    Pending = "󰞌",
  }
}

